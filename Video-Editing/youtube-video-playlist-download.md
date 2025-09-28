# Download Videos from Youtube or Udemy

# [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#usage-and-options)

## [Download Youtube Playlist](https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#output-template-examples)

```
yt-dlp https://youtube.com/playlist?list=PL0g2ZVnQRk3iuwqJBtG5G6hPcphdHGg8W&feature=shared

# Download YouTube playlist videos in separate directory indexed by video order in a playlist
$ yt-dlp -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "https://youtube.com/playlist?list=PL0g2ZVnQRk3iihkd7SwNb0QPQAx3Nc3UQ&feature=shared"

# Prefix playlist index with " - " separator, but only if it is available
$ yt-dlp -o "%(playlist_index&{} - |)s%(title)s.%(ext)s" BaW_jenozKc "https://www.youtube.com/user/TheLinuxFoundation/playlists"

# Download all playlists of YouTube channel/user keeping each playlist in separate directory:
$ yt-dlp -o "%(uploader)s/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "https://www.youtube.com/user/TheLinuxFoundation/playlists"

# Check available formats
yt-dlp -F "https://youtube.com/playlist?list=PLbZxdQd9WcS0w2N8U1t6A5_GnEeWmRB4Y&feature=shared"

yt-dlp -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "https://youtube.com/playlist?list=PLbZxdQd9WcS0w2N8U1t6A5_GnEeWmRB4Y&feature=shared"

# download in 360p format
yt-dlp -f 134+140 -o "%(title)s.%(ext)s" "https://www.youtube.com/watch?v=l2B074Hnb7E"

# download in 480p format
yt-dlp --cookies-from-browser brave -f 135+140 -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "https://youtube.com/playlist?list=PLbZxdQd9WcS0w2N8U1t6A5_GnEeWmRB4Y&feature=shared"

# download in 480p, but use 360p as fallback
yt-dlp --cookies-from-browser brave -f "135+140/244+251/134+140/243+251/best[height<=480]/best[height<=360]/best" -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" \
    "https://youtube.com/playlist?list=PLbZxdQd9WcS0w2N8U1t6A5_GnEeWmRB4Y&feature=shared"

# download in 480p, but use 360p as fallback. Start at x video number
yt-dlp --cookies-from-browser brave -f "135+140/244+251/134+140/243+251/best[height<=480]/best[height<=360]/best" -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" \
    --playlist-start 120 \
    "https://youtube.com/playlist?list=PLbZxdQd9WcS0w2N8U1t6A5_GnEeWmRB4Y&feature=shared"

# download between x and y video numbers
yt-dlp --cookies-from-browser brave -f "135+140/244+251/134+140/243+251/best[height<=480]/best[height<=360]/best" -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" \
    --playlist-items 351-400 \
    "https://youtube.com/playlist?list=PLbZxdQd9WcS0w2N8U1t6A5_GnEeWmRB4Y&feature=shared"
```

## [Download Udemy Playlist](https://github.com/yt-dlp/yt-dlp/issues/7770#issuecomment-1890829103)

```
yt-dlp --cookies-from-browser firefox https://www.udemy.com/course/postgresql-replication-high-availability-ha-and-scalability
yt-dlp --cookies-from-browser chrome https://www.udemy.com/course/postgresql-replication-high-availability-ha-and-scalability

# Download Udemy course keeping each chapter in separate directory under MyVideos directory in your home
yt-dlp --cookies-from-browser -P "~/Downloads/PostgreSQL" -o "%(playlist)s/%(chapter_number)s - %(chapter)s/%(title)s.%(ext)s" "https://www.udemy.com/course/postgresql-replication-high-availability-ha-and-scalability"

```