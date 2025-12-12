#!/bin/bash

# Set default directory or accept as an argument
VideoCourseDirectory=${1:-'/stale-storage/Study-Zone/DBMS/Distributed Systems in One Lesson'}

# Description: Function to loop through *.mkv files and compress to *.mp4
echo "Processing directory: $VideoCourseDirectory"

# Find all .mkv files and store them in an array
mapfile -t videoFiles < <(find "$VideoCourseDirectory" -type f -name "*.mkv" | sort)

# Count files
fileCount=${#videoFiles[@]}
echo "$fileCount files to process.."

# Process each file
for file in "${videoFiles[@]}"; do
  # Extract directory, basename, and output file path
  fileDirectory=$(dirname "$file")
  baseName=$(basename "$file" .mkv)
  preFile="$fileDirectory/$baseName.mkv"
  postFile="$fileDirectory/$baseName.mp4"

  # Print processing message
  echo -e "\nProcessing file '$preFile'.."

  # Execute ffmpeg command to compress the video
  ffmpeg -i "$preFile" -y -vcodec libx265 -crf 20 "$postFile"

done

echo "Processing completed!"
