#!/bin/bash
# turns image frames into a video

# %04d.png: file name pattern. 4 numers and extension. could be img%o4d.png for instance
# out3.mp4: out name

# should be run on the same directory as the frames

# TODO make variable:
# - frame name pattern
# - fps
# - out name

ffmpeg -i %05d.png -c:v libx264 -r 24 -pix_fmt yuv420p out-r.mp4
#ffmpeg -i %05d.png -c:v libx264 -framerate 24 -pix_fmt yuv420p out.mp4
#ffmpeg -i %05d.png -c:v libx264 -vf fps=24 -pix_fmt yuv420p out.mp4
#ffmpeg -i frame-%04d.png -c:v libx264 -vf fps=29.97 -pix_fmt yuv420p out.mp4
#ffmpeg -i frame-%04d.png -c:v libx264 -vf fps=24 -pix_fmt yuv420p out.mp4
