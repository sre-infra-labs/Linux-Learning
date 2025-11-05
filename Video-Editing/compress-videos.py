import subprocess
import os

def convert_mkv_to_mp4(video_directory, crf_value=20):
    """
    Converts MKV files in a given directory to MP4 using ffmpeg,
    processing them in lexicographical order (alphabetical).

    Args:
        video_directory (str): The directory containing the MKV files.
        crf_value (int, optional): The Constant Rate Factor (CRF) value for the MP4 encoding.
                                     Defaults to 20.
    """

    try:
        video_files = sorted([f for f in os.listdir(video_directory)
                             if os.path.isfile(os.path.join(video_directory, f)) and f.endswith(".mkv")])

        for video_file in video_files:
            pre_file = os.path.join(video_directory, video_file)
            post_file = os.path.join(video_directory, video_file.replace(".mkv", ".mp4"))

            if os.path.exists(post_file):
                print(f"File '{post_file}' already exists. Skipping...")
            else:
                print(f"Processing file '{pre_file}'", end='\r')
                try:
                    subprocess.run(
                        ["ffmpeg", "-i", pre_file, "-vcodec", "libx265", "-crf", str(crf_value), post_file],
                        check=True,
                        capture_output=True,
                        text=True
                    )
                    print(f"Successfully converted '{pre_file}' to '{post_file}'")
                except subprocess.CalledProcessError as e:
                    print(f"Error converting '{pre_file}': {e}")
                    print(e.stderr)

    except FileNotFoundError:
        print(f"Error: Directory '{video_directory}' not found.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


# Example usage:
video_directory = '/home/saanvi/Downloads/SSR-Recordings'  # Replace with your actual directory
convert_mkv_to_mp4(video_directory)