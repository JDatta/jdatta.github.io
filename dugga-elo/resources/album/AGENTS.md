# Album media policy

ImageMagick is installed and may be used for image-related tasks. FFmpeg is
installed and may be used for video-related tasks.

The JPEGs directly in this directory are the 45 canonical sources. Preserve
their bytes and filenames. The `web/` directory contains checked-in display
derivatives used by the page; it is not a source archive and is not generated at
deployment time.

## Rebuild display derivatives

Natural filename order is the album order. Confirm the source sequence first:

```bash
find . -maxdepth 1 -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' \) \
  -printf '%f\n' | LC_ALL=C sort -V
```

For every source except `image-00009.jpg`, auto-orient, strip metadata, limit the
longest edge to 1600 pixels, and write a progressive JPEG at quality 84:

```bash
mkdir -p web
for source in image-*.jpg; do
  if [ "$source" = image-00009.jpg ]; then
    cp -p -- "$source" "web/$source"
  else
    magick "$source" -auto-orient -strip -resize '1600x1600>' \
      -interlace Plane -quality 84 "web/$source"
  fi
done
```

Image 9 remains unchanged because its longest edge is already below 1600 pixels.
Every output must open, have neither dimension above 1600, and stay below
600 KiB. Re-encode only an oversized output with `-define jpeg:extent=575KB`.

After rebuilding, update the frozen `ALBUM_IMAGES` dimensions in the project
`index.html` if any output dimension changed. Do not add a runtime directory
listing or a generated deployment manifest.

