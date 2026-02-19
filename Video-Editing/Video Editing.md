## Download video
https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#usage-and-options


# Set directory
```
cd "/stale-storage/Study-Zone/C, C++, Java, Golang/Ultimate Go: Advanced Concepts"
```

# Cut and Compress Video File
```
ffmpeg -i 'Lsn 01: Strings and Formatted Output.mkv' -ss 00:00:00 -to 00:54:05 -vcodec libx265 -crf 20 'Lsn 01: Strings and Formatted Output.mp4' # 54m - done
ffmpeg -i 'Lsn 02: Memory and Data Symentics.mkv' -ss 00:00:00 -to 02:07:27 -vcodec libx265 -crf 20 'Lsn 02: Memory and Data Symentics.mp4' # 2h 7m - done
ffmpeg -i 'Lsn 03: Data Structures.mkv' -ss 00:00:00 -to 02:05:56 -vcodec libx265 -crf 20 'Lsn 03: Data Structures.mp4' # 2h 5m - done
ffmpeg -i 'Lsn 04 - Part 4.1.1 - 4.1.2.mkv' -ss 00:00:00 -to 00:31:17 -vcodec libx265 -crf 20 'Lsn 04 Part 1: Decoupling.mp4' # done
ffmpeg -i 'Lsn 04 - Lsn 14.mkv' -ss 00:00:00 -to 01:02:02 -vcodec libx265 -crf 20 'Lsn 04 Part 2: Decoupling.mp4' # done
ffmpeg -i 'Lsn 04 - Lsn 14.mkv' -ss 01:02:02 -to 02:26:59 -vcodec libx265 -crf 20 'Lsn 05: Composition.mp4' # 1h 25m - done
ffmpeg -i 'Lsn 04 - Lsn 14.mkv' -ss 02:27:03 -to 03:11:23 -vcodec libx265 -crf 20 'Lsn 06: Error Handling.mp4' # 44m - done
ffmpeg -i 'Lsn 04 - Lsn 14.mkv' -ss 03:11:27 -to 03:38:30 -vcodec libx265 -crf 20 'Lsn 07: Packgaging.mp4' # 27m - done

ffmpeg -i 'Lsn 04 - Lsn 14.mkv' -ss 03:38:34 -to 04:58:23 -vcodec libx265 -crf 20 'Lsn 08: Go Routines.mp4' # 1h 20m - wip
ffmpeg -i 'Lsn 04 - Lsn 14.mkv' -ss 04:58:26 -to 05:20:37 -vcodec libx265 -crf 20 'Lsn 09: Data Races.mp4' # 22m
ffmpeg -i 'Lsn 04 - Lsn 14.mkv' -ss 05:20:43 -to 06:16:45 -vcodec libx265 -crf 20 'Lsn 10: Channels.mp4' # 54m
ffmpeg -i 'Lsn 04 - Lsn 14.mkv' -ss 06:16:51 -to 06:35:20 -vcodec libx265 -crf 20 'Lsn 11: Concurrency Patterns.mp4' # 18m
ffmpeg -i 'Lsn 04 - Lsn 14.mkv' -ss 06:35:24 -to 07:14:40 -vcodec libx265 -crf 20 'Lsn 12: Testing.mp4' # 39m
ffmpeg -i 'Lsn 04 - Lsn 14.mkv' -ss 07:14:43 -to 07:44:18 -vcodec libx265 -crf 20 'Lsn 13: Benchmarks.mp4' # 29m
ffmpeg -i 'Lsn 04 - Lsn 14.mkv' -ss 07:44:23 -to 09:30:49 -vcodec libx265 -crf 20 'Lsn 14: Profiling and Tracing.mp4' # 1h 46m


```

## Merge multiple Videos
```
# Add video file names into a text file in below format
cat <<EOF > Videos-2-Merge.txt

file 'Lsn 04 Part 1: Decoupling.mp4'
file 'Lsn 04 Part 2: Decoupling.mp4'
EOF


# Now, merge the video files
ffmpeg -f concat -safe 0 -i Videos-2-Merge.txt -c copy 'Lsn 04: Decoupling.mp4'

# Merge & Compress video files
ffmpeg -f concat -safe 0 -i Videos-2-Merge.txt -vcodec libx265 -crf 20 '04_1 - IEPT01 Online Delivery 20210315 - Day 4 _ SQLskills.mp4'
```


## Merge, Cut, Compress, Convert Videos
`
$ ffmpeg -f concat -safe 0 -i Videos-2-Merge.txt -vcodec libx265 -ss 00:00:00 -to 03:52:21 -crf 20 "01_1 - IEPTO2 Online Delivery Content 20210412 - Day 1 _ SQLskills.mp4"
`

####################################################################################
####################################################################################
## Command to Combine Audio and Video from YouTube
https://en1.savefrom.net/1-youtube-video-downloader-3vV/

## for synchronized video/audio files with Compressed format
```
ffmpeg -i tutorial-video.mp4 -i videoplayback.mp3 -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 "Vim-tutorial-for-beginners.mp4"

ffmpeg -i 'Analytics for not-so-big data with DuckDB - David Ostrovsky - NDC Oslo 2025 - Video.mp4' -i 'Analytics for not-so-big data with DuckDB - David Ostrovsky - NDC Oslo 2025.mp3' -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 'Analytics for not-so-big data with DuckDB - David Ostrovsky - NDC Oslo 2025.mp4'
```

#


####################################################################################
####################################################################################

## Full Convert/Compress
`ffmpeg -i "InputFile.mkv" -vcodec libx265 -crf 20 "InputFile.mp4"`

## Partial Convert/Compress
`ffmpeg -i "InputFile.mkv" -ss 00:00:00 -to 00:02:00 -vcodec libx265 -crf 20 "InputFile.mp4"`

####################################################################################
####################################################################################

## Compress All Videos in Directory
```
[CmdletBinding()]
Param (
  [Parameter(Mandatory=$false)]
  [String]$VideoDirectory = '/study-zone/BrentOzar-Recordings/02 - Fundamentals of Index Tuning'
)
Set-Location $VideoDirectory

$videoFiles = @()
$videoFiles += Get-ChildItem -File | Where-Object {$_.Extension -eq '.mkv'}

#$videoFiles | Select-Object * -First 1 | fl
clear
foreach($file in $videoFiles) {
  $preFile = $file.BaseName+'.mkv'
  $postFile = $file.BaseName + '.mp4'
  "Processing file '$preFile'" | Write-Host -ForegroundColor Cyan
  #$preFile = $preFile.Replace("'","\'")
  #$postFile = $postFile.Replace("'", "\'")
  #"ffmpeg -i '$preFile' -vcodec libx265 -crf 20 '$postFile';"
  #sh -c "ffmpeg -i `"$preFile`" -vcodec libx265 -crf 20 `"$postFile`";"
  ffmpeg -i `"$preFile`" -vcodec libx265 -crf 20 `"$postFile`";
  #break;
}
```

####################################################################################
####################################################################################

## Cut a video
```
ffmpeg -i input.mp4 -ss 00:00:00 -to 03:21:16 -c copy output1.mp4
ffmpeg -i input.mp4 -ss 00:10:00 -to 00:20:00 -c copy output2.mp4


/**
* -i  input file
* -ss start time in seconds or in hh:mm:ss
* -to end time in seconds or in hh:mm:ss
* -c codec to use
*/
```

####################################################################################
####################################################################################


