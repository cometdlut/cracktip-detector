#!/bin/bash

rm -f crop-*.jpeg
rm -f crackgrowth.mp4

for f in *jpeg; do
    convert -crop 1920x1080+0+0 $f crop-$f
done

ffmpeg -r 25 -i crop-%03d.jpeg -codec:v libx264 crackgrowth.mp4


