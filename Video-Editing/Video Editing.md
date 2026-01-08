## Download video
https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#usage-and-options


# Set directory
```
cd "/stale-storage/Study-Zone/Data_Engineering/Data Engineering Foundations/Part 1: Using Spark, Hive, and Hadoop Scalable Tools"
```

# Cut and Compress Video File
```
ffmpeg -i "recording-2026-01-07_20.26.37.mkv" -ss 00:00:00 -to 00:05:20 -vcodec libx265 -crf 20 "Introduction.mp4" -- done
ffmpeg -i "recording-2026-01-07_20.26.37.mkv" -ss 00:05:23 -to 01:01:43 -vcodec libx265 -crf 20 "Lesson 1: Background Concepts.mp4" # 56m - wip
ffmpeg -i "recording-2026-01-07_20.26.37.mkv" -ss 01:01:47 -to 01:58:27 -vcodec libx265 -crf 20 "Lesson 2: Working with Scalable Systems.mp4" # 56m - wip
ffmpeg -i "recording-2026-01-07_20.26.37.mkv" -ss 01:58:31 -to 02:39:53 -vcodec libx265 -crf 20 "Lesson 3: Using the Hadoop HDFS File System.mp4" # 41m - wip
ffmpeg -i "recording-2026-01-07_20.26.37.mkv" -ss 02:39:57 -to 04:23:13 -vcodec libx265 -crf 20 "Lesson 4: Using Hadoop MapReduce.mp4" # 1h 43m - wip
ffmpeg -i "recording-2026-01-07_20.26.37.mkv" -ss 04:23:19 -to 05:00:24 -vcodec libx265 -crf 20 "Lesson 5: Using the Hive Scalable Database.mp4" # 37m - wip
ffmpeg -i "recording-2026-01-07_20.26.37.mkv" -ss 05:00:30 -to 06:19:39 -vcodec libx265 -crf 20 "Lesson 6 - part 1: Using Apache PySpark.mp4" # 1h 20m - wip

ffmpeg -i "recording-2026-01-08_02.48.55.mkv" -ss 00:00:00 -to 00:26:56 -vcodec libx265 -crf 20 "Lesson 6 - part 2: Using Apache PySpark.mp4" # 26m 56s
ffmpeg -i "recording-2026-01-08_02.48.55.mkv" -ss 00:27:02 -to 00:29:31 -vcodec libx265 -crf 20 "Summary.mp4" # 2m

cd "/stale-storage/Study-Zone/Data_Engineering/Data Engineering Foundations/Part 2: Building Data Pipelines with Kafka and Nifi"

ffmpeg -i "recording-2026-01-08_03.20.18.mkv" -ss 00:00:00 -to 00:04:11 -vcodec libx265 -crf 20 "Introduction.mp4" # 4m - done
ffmpeg -i "recording-2026-01-08_03.20.18.mkv" -ss 00:04:15 -to 01:37:02 -vcodec libx265 -crf 20 "Lesson 7: Working with the Kafka Message Broker.mp4" # 1h 33m - wip
ffmpeg -i "recording-2026-01-08_03.20.18.mkv" -ss 01:37:07 -to 02:56:04 -vcodec libx265 -crf 20 "Lesson 8: Working with NiFi Dataflow.mp4" # 1h 19m - wip
ffmpeg -i "recording-2026-01-08_03.20.18.mkv" -ss 02:56:10 -to 04:27:07 -vcodec libx265 -crf 20 "Lesson 9: Big Data Movement and Storage.mp4" # 1h 31m - wip
ffmpeg -i "recording-2026-01-08_03.20.18.mkv" -ss 04:27:12 -to 04:28:58 -vcodec libx265 -crf 20 "Summary.mp4" # 2m
```

## Merge multiple Videos
```
# Add video file names into a text file in below format
cat <<EOF > Videos-2-Merge.txt

file 'Lesson 6 - part 1: Using Apache PySpark.mp4'
file 'Lesson 6 - part 2: Using Apache PySpark.mp4'
EOF


# Now, merge the video files
ffmpeg -f concat -safe 0 -i Videos-2-Merge.txt -c copy 'Lesson 6: Using Apache PySpark.mp4'

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


