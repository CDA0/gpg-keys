#!/bin/bash

# Split key into manageable chunks
split -C 1250 "$1" "$1"-split-

for file in "$1"-split-??; do
  # Generate a qr code for the chunk
  <"$file" qrencode -s 3 -d 150 -o "$file".qr -l H

  # remove the part of the key
  shred --zero --remove "$file"

  # Add a header to the image
  convert $file.qr \
    -gravity north \
    -pointsize 8 \
    -background orange \
    -splice 0x32 \
    -annotate +0+4 "$file" \
    $file.png

  # remove the generated qr code
  shred --zero --remove "$file".qr
done

# take all the qr codes with headers and add them to a pdf
convert *.png \
  -density 150 \
  -page A4 \
  $1.pdf

# remove all the pngs
shred --zero --remove *.png

# print the pdf to the defualt cups printer
lp -o print-quality=5 -o sides=two-sided-long-edge -o media=a4 $1.pdf

# remove the generated pdf
shred --zero --remove $1.pdf
