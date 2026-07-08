#!/usr/bin/env python3
"""Download a YouTube playlist to a local directory with format inspection and x265 compression.

Features:
  - Inspects available formats (video+audio pairs) for each video.
  - Selects best 480p video + opus audio, falls back to 360p.
  - Skips videos already present locally (by embedded video-id or fuzzy title match).
  - Compresses every downloaded video with libx265 (CRF configurable, default 20).
  - Verbose pre/post messages per video and a final summary + cross-comparison.

Usage:
  python3 download-youtube-playlist.py [--directory DIR] [--playlist URL]
      [--video-start-no N] [--video-stop-no M] [--crf 20] [--cookies-browser brave]
"""
import argparse
import json
import os
import re
import subprocess
import sys
from difflib import SequenceMatcher

# Ensure Deno is in PATH for yt-dlp EJS support
deno_path = os.path.expanduser("~/.deno/bin")
if deno_path not in os.environ.get("PATH", ""):
    os.environ["PATH"] = f"{deno_path}:{os.environ.get('PATH', '')}"

DEFAULT_DIR = "/home/saanvi/Videos/Bhajans - YouTube"
DEFAULT_PLAYLIST = (
    "https://www.youtube.com/watch?v=4DkNCgUXbig"
    "&list=PLFUGPe1byxevra8lZU6w9yaiLBlry8pEt"
)
VIDEO_EXTS = (".mp4", ".mkv", ".webm", ".m4v", ".avi", ".mov")


def log(msg):
    print(msg, flush=True)


def norm(text):
    """Lowercase alphanumeric-only form used for fuzzy title comparison."""
    return re.sub(r"[^a-z0-9]", "", text.lower())


def list_local_videos(directory):
    """Return list of (filename, stem) for video files in directory."""
    out = []
    for name in os.listdir(directory):
        if name.lower().endswith(VIDEO_EXTS):
            out.append((name, os.path.splitext(name)[0]))
    return out


def fetch_playlist(playlist, cookies_browser):
    """Return list of dicts with keys: index, id, title."""
    cmd = ["yt-dlp", "--flat-playlist", "--ignore-errors"]
    if cookies_browser:
        cmd += ["--cookies-from-browser", cookies_browser]
    cmd += ["--print", "%(playlist_index)s\t%(id)s\t%(title)s", playlist]
    log(f"Fetching playlist metadata:\n  {playlist}")
    res = subprocess.run(cmd, capture_output=True, text=True)
    entries = []
    for line in res.stdout.splitlines():
        parts = line.split("\t")
        if len(parts) != 3 or not parts[0].strip():
            continue
        idx, vid, title = parts
        try:
            entries.append({"index": int(idx), "id": vid, "title": title})
        except ValueError:
            continue
    if not entries:
        log("ERROR: could not read any playlist entries. yt-dlp stderr:")
        log(res.stderr[-2000:])
    return entries


def find_duplicate(entry, local, threshold):
    """Return (reason, matched_filename) if a local file matches, else (None, None)."""
    for name, stem in local:
        if entry["id"] in name:
            return ("exact video-id", name)
    ntitle = norm(entry["title"])
    if not ntitle:
        return (None, None)
    best, best_name = 0.0, None
    for name, stem in local:
        ratio = SequenceMatcher(None, ntitle, norm(stem)).ratio()
        if ratio > best:
            best, best_name = ratio, name
    if best >= threshold:
        return (f"similar title ({best:.0%})", best_name)
    return (None, None)


def get_best_format(video_id, cookies_browser, target_resolution=360):
    """
    Inspect formats for a video and return the best video+audio format string.
    Prefers specified resolution (360p or 480p) + opus audio, with fallbacks.
    Returns (format_str, description) or (None, error_msg) on failure.
    """
    url = f"https://www.youtube.com/watch?v={video_id}"
    cmd = ["yt-dlp", "-j", "--no-playlist", "--remote-components", "ejs:github"]
    if cookies_browser:
        cmd += ["--cookies-from-browser", cookies_browser]
    cmd.append(url)

    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        return (None, "Could not fetch format info")

    try:
        info = json.loads(res.stdout)
    except json.JSONDecodeError:
        return (None, "Invalid JSON from yt-dlp")

    formats = info.get("formats", [])
    if not formats:
        return (None, "No formats available")

    # Find video formats by resolution and audio format (opus)
    videos_by_res = {360: [], 480: []}
    audio_opus = None

    for fmt in formats:
        height = fmt.get("height")
        vcodec = fmt.get("vcodec", "")
        acodec = fmt.get("acodec", "")
        fmt_id = fmt.get("format_id")

        # Collect video formats by resolution
        if vcodec and vcodec != "none" and height:
            if height in videos_by_res:
                videos_by_res[height].append(fmt_id)

        # Find opus audio
        if acodec == "opus" and not audio_opus:
            audio_opus = fmt_id

    # If no opus found, use any audio
    if not audio_opus:
        for fmt in formats:
            acodec = fmt.get("acodec", "")
            fmt_id = fmt.get("format_id")
            if acodec and acodec != "none":
                audio_opus = fmt_id
                break

    if not audio_opus:
        return (None, "No audio format found")

    # Build format string: try target resolution, then fallback to next best
    if target_resolution == 360:
        if videos_by_res[360]:
            fmt_str = f"{videos_by_res[360][0]}+{audio_opus}"
            desc = f"360p + audio"
            return (fmt_str, desc)
        elif videos_by_res[480]:
            fmt_str = f"{videos_by_res[480][0]}+{audio_opus}"
            desc = f"480p + audio (360p unavailable)"
            return (fmt_str, desc)
    else:  # target_resolution == 480
        if videos_by_res[480]:
            fmt_str = f"{videos_by_res[480][0]}+{audio_opus}"
            desc = f"480p + audio"
            return (fmt_str, desc)
        elif videos_by_res[360]:
            fmt_str = f"{videos_by_res[360][0]}+{audio_opus}"
            desc = f"360p + audio (480p unavailable)"
            return (fmt_str, desc)

    return ("best", "best available")


def download_video(entry, directory, cookies_browser, target_resolution=360):
    """Download one video with best detected format. Return the resulting file path or None on failure."""
    url = f"https://www.youtube.com/watch?v={entry['id']}"

    # Detect best format for this video
    fmt_str, fmt_desc = get_best_format(entry["id"], cookies_browser, target_resolution)
    if fmt_str is None:
        log(f"  ! format detection failed: {fmt_desc}")
        return None

    log(f"  format: {fmt_desc} ({fmt_str})")

    out_tmpl = os.path.join(directory, "%(title).120s.%(ext)s")
    cmd = ["yt-dlp", "--no-playlist", "--no-progress", "-f", fmt_str]
    if cookies_browser:
        cmd += ["--cookies-from-browser", cookies_browser]
    cmd += ["--print", "after_move:filepath", "-o", out_tmpl, url]

    res = subprocess.run(cmd, capture_output=True, text=True)
    path = None
    for line in res.stdout.splitlines():
        if os.path.isabs(line.strip()) and line.strip().lower().endswith(VIDEO_EXTS):
            path = line.strip()

    if path is None or not os.path.exists(path):
        log("  ! download failed. yt-dlp stderr tail:")
        log("  " + res.stderr[-800:].replace("\n", "\n  "))
        return None
    return path


def compress_video(path, crf):
    """Compress with libx265 CRF; replace original. Return final path or None."""
    base = os.path.splitext(path)[0]
    final = base + ".mp4"
    tmp = base + ".x265tmp.mp4"
    cmd = [
        "ffmpeg", "-y", "-i", path,
        "-c:v", "libx265", "-crf", str(crf),
        "-c:a", "aac", "-b:a", "192k", tmp,
    ]
    log(f"  compressing with libx265 (crf {crf}) ...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0 or not os.path.exists(tmp):
        log("  ! compression failed. ffmpeg stderr tail:")
        log("  " + res.stderr[-800:].replace("\n", "\n  "))
        if os.path.exists(tmp):
            os.remove(tmp)
        return path  # keep the uncompressed download
    if os.path.abspath(path) != os.path.abspath(final) and os.path.exists(path):
        os.remove(path)
    elif os.path.exists(path):
        os.remove(path)
    os.rename(tmp, final)
    return final


def human_size(path):
    try:
        return f"{os.path.getsize(path) / (1024 * 1024):.1f} MB"
    except OSError:
        return "?"


def main():
    p = argparse.ArgumentParser(description="Download a YouTube playlist with de-dup and x265 compression.")
    p.add_argument("--directory", default=DEFAULT_DIR)
    p.add_argument("--playlist", default=DEFAULT_PLAYLIST)
    p.add_argument("--video-start-no", type=int, default=1)
    p.add_argument("--video-stop-no", type=int, default=None,
                   help="Last playlist index to process (inclusive). Default: all.")
    p.add_argument("--resolution", type=int, default=360, choices=[360, 480],
                   help="Video resolution: 360p (default, smaller) or 480p (larger).")
    p.add_argument("--crf", type=int, default=20,
                   help="libx265 quality (lower=better quality but larger file). Default: 20. Try 28 or 32 for smaller files.")
    p.add_argument("--cookies-browser", default="brave")
    p.add_argument("--similarity", type=float, default=0.85,
                   help="Fuzzy-match threshold (0-1) for detecting duplicate titles.")
    p.add_argument("--no-compress", action="store_true")
    args = p.parse_args()

    os.makedirs(args.directory, exist_ok=True)
    log("=" * 70)
    log(f"Target directory : {args.directory}")
    log(f"Playlist         : {args.playlist}")
    log(f"Resolution       : {args.resolution}p")
    log(f"Compression CRF  : {args.crf}")
    log("=" * 70)

    entries = fetch_playlist(args.playlist, args.cookies_browser)
    playlist_total = len(entries)
    if not entries:
        sys.exit(1)

    stop = args.video_stop_no if args.video_stop_no is not None else playlist_total
    selected = [e for e in entries if args.video_start_no <= e["index"] <= stop]
    log(f"Playlist videos  : {playlist_total}")
    log(f"Processing range : #{args.video_start_no} to #{stop} ({len(selected)} videos)\n")

    stats = {"downloaded": [], "skipped": [], "similar": [], "failed": []}

    for e in selected:
        header = f"[{e['index']}/{playlist_total}] {e['title']}"
        log("-" * 70)
        log(header)
        local = list_local_videos(args.directory)
        reason, match = find_duplicate(e, local, args.similarity)
        if reason:
            bucket = "skipped" if "video-id" in reason else "similar"
            stats[bucket].append(e["title"])
            log(f"  SKIP ({reason}) -> already have: {match}")
            continue
        log(f"  downloading ({args.resolution}p with fallback) ...")
        path = download_video(e, args.directory, args.cookies_browser, args.resolution)
        if not path:
            stats["failed"].append(e["title"])
            continue
        log(f"  downloaded: {os.path.basename(path)} ({human_size(path)})")
        if not args.no_compress:
            path = compress_video(path, args.crf)
        log(f"  DONE: {os.path.basename(path)} ({human_size(path)})")
        stats["downloaded"].append(e["title"])

    print_summary(stats, playlist_total, args.directory)


def print_summary(stats, playlist_total, directory):
    local_now = len(list_local_videos(directory))
    log("\n" + "=" * 70)
    log("SUMMARY")
    log("=" * 70)
    log(f"  Downloaded : {len(stats['downloaded'])}")
    log(f"  Skipped    : {len(stats['skipped'])} (already present by video-id)")
    log(f"  Similar    : {len(stats['similar'])} (likely duplicates by title)")
    log(f"  Failed     : {len(stats['failed'])}")
    for key in ("downloaded", "similar", "failed"):
        if stats[key]:
            log(f"\n  {key.upper()}:")
            for t in stats[key]:
                log(f"    - {t}")
    log("\n" + "-" * 70)
    log("CROSS-COMPARISON")
    log(f"  Videos in playlist        : {playlist_total}")
    log(f"  Video files in local dir  : {local_now}")
    diff = playlist_total - local_now
    log(f"  Difference (playlist-local): {diff}")
    log("=" * 70)


if __name__ == "__main__":
    main()
