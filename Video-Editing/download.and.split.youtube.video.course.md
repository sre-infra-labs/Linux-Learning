# Split Video on disk into multiple videos under [Chapter(s)/][Lesson(s)]

Folder -> /stale-storage/Study-Zone/Cloud & DevOps/DevOps & System Design/Master TERRAFORM in ONE VIDEO with AWS | DevOps For Beginners [HINDI] | MPrashant
YouTube URL -> https://youtu.be/4JYtAf4M88Y
Video file in above folder (already downloaded) -> Master TERRAFORM in ONE VIDEO with AWS ｜ DevOps For Beginners  [HINDI] ｜ MPrashant [4JYtAf4M88Y].webm
#Output Naming -> chp_NN - Chapter_Name/lsnNNN - Lesson_Name.mkv
Output Naming -> chp_NN - Chapter_Name.mkv

Cut by stream copy (-c copy): each clip starts on the keyframe at or before the chapter/lesson start, so it may begin up to ~0.5 s early.
Video lsn number should always increase irrespective of chapter.

## Ignore below yt-dlp commands to download youtube video.
```bash
# Check available formats
yt-dlp --cookies-from-browser brave -F https://youtu.be/4JYtAf4M88Y

# How to choose Video + Audio format
    # Choose VIDEO based on RESOLUTION + FPS + VBR
    # Choose AUDIO with ACODEC = 'opus' and highest VBR
yt-dlp -f 303+251 https://youtu.be/4JYtAf4M88Y
```

# Video sections [Chapter(s)/][Lesson(s)]

00:00:00 Course Intro
00:04:24 What is Terraform?
00:09:28 Terraform Installation - Windows
00:10:50 Terraform Installation - MAC
00:13:48 AWS Account - SignUP
00:15:36 AWS User Setup
00:22:02 AWS CLI Setup - Windows
00:23:05 AWS CLI Setup - MAC
00:23:44 AWS CLI USER ACCESS Configure on VSCode
00:30:28 AWS EC2 Manually
00:33:37 First Terraform Config To Create EC2 Instance
00:41:26 Terraform INIT, PLAN, APPLY, DESTROY
00:45:01 Terraform - Resource Modify
00:49:00 Terraform -  Resource Delete
00:51:14 Terraform Config and State Overview
00:56:40 Terraform Variables & Outputs
01:04:28 AWS S3 Overview
01:08:56 Terraform - S3 Bucket Create and Upload Files
01:16:42 Terraform - Random Provider
01:23:34 Terraform Backend - Remote State Management with S3
01:33:07 Project - Host Static Website Using Terraform
02:01:23 Understand AWS VPC
02:18:54 AWS VPC Manually
02:31:00 AWS VPC Using Terraform 
02:42:54 AWS EC2 + VPC
02:45:17 Project - EC2 + VPC + NGINX + HTTP Access
03:05:09 Terraform Data Source
03:21:32 VPC & SG with Data Source
03:33:31 Task: Create EC2 using Existing VPC
03:44:38 Terraform Variables - Types, Validation, ENV, tfvars, auto.tfvars
04:20:03 Terraform Operators & Expressions - List, Map, Object, Loops
04:40:00 Terraform Functions
04:49:07 Multiple Resources - COUNT
05:27:26 Multiple Resources - FOR_EACH 
05:42:20 Project - AWS IAM Management
06:22:21 Terraform Modules
06:47:10 AWS EC2 using Public Terraform Module
06:58:52 Creating Our Own Terraform Module 
07:57:47 Terraform Registry - Publish our module
08:18:15 Terraform Resources Dependency
08:23:29 Terraform Resources Lifecycle
08:36:25 Terraform Validations
08:47:01 Terraform State Modifications
08:57:56 Terraform Import Command
09:05:57 Terraform Workspace
09:18:38 Terraform Cloud with GitHUB



