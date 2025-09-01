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


```

## [Download Udemy Playlist](https://github.com/yt-dlp/yt-dlp/issues/7770#issuecomment-1890829103)

```
yt-dlp --cookies-from-browser firefox https://www.udemy.com/course/postgresql-replication-high-availability-ha-and-scalability
yt-dlp --cookies-from-browser chrome https://www.udemy.com/course/postgresql-replication-high-availability-ha-and-scalability

# Download Udemy course keeping each chapter in separate directory under MyVideos directory in your home
yt-dlp --cookies-from-browser -P "~/Downloads/PostgreSQL" -o "%(playlist)s/%(chapter_number)s - %(chapter)s/%(title)s.%(ext)s" "https://www.udemy.com/course/postgresql-replication-high-availability-ha-and-scalability"

```