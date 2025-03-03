#!/bin/bash
# crop input as square

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_image_path> <side_to_crop>"
  echo "side_to_crop can be one of: top, bottom, left, right"
  exit 1
fi

input_image="$1"
side_to_crop="$2"
output_image="output_square.png"

# Check if the input file exists
if [ ! -f "$input_image" ]; then
  echo "Error: File '$input_image' not found!"
  exit 1
fi

# Get the dimensions of the input image
read width height <<< $(identify -format "%w %h" "$input_image")

# Determine the size of the square (the smaller dimension)
square_size=$(( width < height ? width : height ))

# Calculate crop dimensions based on the side to crop
# TODO: check if top/bottom work
case "$side_to_crop" in
  top)
    crop_width="$width"
    crop_height="$square_size"
    crop_x="0"
    crop_y="$(( height - square_size ))"
    ;;
  bottom)
    crop_width="$width"
    crop_height="$square_size"
    crop_x="0"
    crop_y="0"
    ;;
  left)
    crop_width="$square_size"
    crop_height="$height"
    crop_x="0"
    crop_y="0"
    ;;
  right)
    crop_width="$square_size"
    crop_height="$height"
    crop_x="$(( width - square_size ))"
    crop_y="0"
    ;;
  *)
    echo "Error: Invalid side_to_crop value. Use one of: top, bottom, left, right."
    exit 1
    ;;
esac

# Perform the cropping using ImageMagick
convert "$input_image" -crop ${crop_width}x${crop_height}+${crop_x}+${crop_y} +repage "$output_image"

if [ $? -eq 0 ]; then
  echo "Image cropped successfully! Saved as $output_image"
else
  echo "Error: Failed to crop the image."
fi
