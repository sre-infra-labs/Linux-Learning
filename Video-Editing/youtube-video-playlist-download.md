# Download Videos from Youtube or Udemy

# [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#usage-and-options)

## [Download Youtube Playlist](https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#output-template-examples)

```
yt-dlp https://youtube.com/playlist?list=PL0g2ZVnQRk3iuwqJBtG5G6hPcphdHGg8W&feature=shared

yt-dlp --cookies-from-browser brave https://www.youtube.com/watch?v=dU7GwCOgvNY

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
yt-dlp --cookies-from-browser brave https://www.udemy.com/course/postgresql-replication-high-availability-ha-and-scalability
yt-dlp --cookies-from-browser chrome https://www.udemy.com/course/postgresql-replication-high-availability-ha-and-scalability

```

## Download OReilly Course

```
# Download Recorded Video
yt-dlp --cookies-from-browser brave "https://event.on24.com/eventRegistration/console/apollox/mainEvent?&eventid=4956056&sessionid=1&username=&partnerref=&format=fhvideo1&mobile=&flashsupportedmobiledevice=&helpcenter=&key=8E7A3FB0364D2AD79DF21316BD18D19A&newConsole=true&nxChe=true&newTabCon=true&consoleEarEventConsole=false&consoleEarCloudApi=false&text_language_id=en&playerwidth=748&playerheight=526&referrer=https%3A%2F%2Fevent.on24.com%2Finterface%2Fregistration%2Fautoreg%2Findex.html%3Fsessionid%3D1%26eventid%3D4956056%26key%3D8E7A3FB0364D2AD79DF21316BD18D19A%26email%3D0196795a-2be0-4b40-ae46-6cece78cecd4%2540platform%26firstname%3DA%26lastname%3DD%26deletecookie%3Dtrue%26event_email%3DN%26marketing_email%3DN%26std1%3D0642572186937%26std2%3D0642572186951%26std3%3Defdb66d0-7015-4698-bc7e-122b63a02f00%26std4%3D1%26std5%3D0&eventuserid=778206362&contenttype=A&mediametricsessionid=670927721&mediametricid=6963043&usercd=778206362&mode=launch"

# Download Video Course
yt-dlp --cookies-from-browser brave -P "~/Downloads" -o "%(playlist)s/%(playlist_index)03d - %(title)s.%(ext)s" "https://learning.oreilly.com/videos/postgresql-mistakes-and/9781633436879VE"


```

# Download hotstar videos
```
yt-dlp -f "video-avc1-4+audio-und-mp4a-2" --cookies-from-browser brave -P "~/Downloads" -o "%(playlist)s/%(playlist_index)03d - %(title)s.%(ext)s" "https://www.hotstar.com/in/shows/mahabharat/435"
```


# Compress videos from folder
```
`ffmpeg -i "InputFile.mkv" -vcodec libx265 -crf 20 "InputFile.mp4"`

ffmpeg -i "video_20250709_110243.mp4" -vcodec libx265 -crf 20 "flat_203.mp4"
```