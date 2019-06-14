import os
from pathlib import Path
import subprocess
import logging
import sys

VIDEO_EXTENSION = ".mp4"
COMPRESSED_SUFFIX = "compressed"


initial_path = "."
if len(sys.argv) > 1:
    initial_path = sys.argv[1]
p = Path(initial_path)

videos_to_compress = [f for f in p.iterdir() if f.is_file() and f.suffix == VIDEO_EXTENSION and COMPRESSED_SUFFIX not in f.name]
for video in videos_to_compress:
    output_name = video.with_name("{}_{}{}".format(video.stem, COMPRESSED_SUFFIX, video.suffix))
    print(subprocess.check_output(["HandBrakeCLI", "-i" , video.as_posix(), "-o", output_name, "-e", "x264", "-q", "20", "--encoder-preset", "veryfast"]))
    print(subprocess.check_output(["rm", video.as_posix()]))
