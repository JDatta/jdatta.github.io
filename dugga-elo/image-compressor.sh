#!/usr/bin/env bash

set -Eeuo pipefail

readonly MAX_BYTES=$((600 * 1024))
readonly TARGET_SIZE="575KB"

usage() {
  printf 'Usage: %s INPUT_DIR OUTPUT_DIR\n' "${0##*/}" >&2
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

# Print a sortable YYYYMMDDhhmmss value when RAW contains a common EXIF/XMP
# timestamp. Nothing here consults filesystem timestamps.
normalize_metadata_date() {
  local raw=$1

  if [[ $raw =~ ([0-9]{4})[-:]([0-9]{2})[-:]([0-9]{2})[T[:space:]]([0-9]{2}):([0-9]{2}):([0-9]{2}) ]]; then
    printf '%s%s%s%s%s%s' \
      "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" \
      "${BASH_REMATCH[4]}" "${BASH_REMATCH[5]}" "${BASH_REMATCH[6]}"
    return 0
  fi

  return 1
}

# Set SORT_DATE and DATE_SOURCE. Metadata takes precedence; filenames are used
# only when metadata has no usable date. Unknown dates sort last by filename.
get_sort_date() {
  local image=$1
  local base metadata value
  local -a metadata_values

  SORT_DATE='99999999999999'
  DATE_SOURCE='unknown'

  metadata=$(magick identify -quiet -format \
    '%[EXIF:DateTimeOriginal]|%[EXIF:DateTimeDigitized]|%[EXIF:DateTime]|%[xmp:CreateDate]|%[xmp:DateCreated]' \
    "$image" 2>/dev/null || true)
  IFS='|' read -r -a metadata_values <<< "$metadata"

  for value in "${metadata_values[@]}"; do
    if SORT_DATE=$(normalize_metadata_date "$value"); then
      DATE_SOURCE='metadata'
      return
    fi
  done

  base=${image##*/}
  if [[ $base =~ (^|[^0-9])((19|20)[0-9]{12})([^0-9]|$) ]]; then
    SORT_DATE=${BASH_REMATCH[2]}
    DATE_SOURCE='filename'
  elif [[ $base =~ (^|[^0-9])((19|20)[0-9]{6})([^0-9]|$) ]]; then
    SORT_DATE="${BASH_REMATCH[2]}000000"
    DATE_SOURCE='filename (date only)'
  fi
}

if (( $# != 2 )); then
  usage
  exit 2
fi

command -v magick >/dev/null 2>&1 || die 'ImageMagick (magick) is required.'
command -v find >/dev/null 2>&1 || die 'find is required.'
command -v sort >/dev/null 2>&1 || die 'sort is required.'

input_dir=$1
output_dir=$2

[[ -d $input_dir ]] || die "Input directory does not exist: $input_dir"
mkdir -p -- "$output_dir"

input_dir=$(realpath -- "$input_dir")
output_dir=$(realpath -- "$output_dir")
[[ $input_dir != "$output_dir" ]] || die 'Input and output directories must differ.'

work_dir=$(mktemp -d -- "$output_dir/.image-compressor.XXXXXX")
cleanup() {
  rm -rf -- "$work_dir"
}
trap cleanup EXIT HUP INT TERM

declare -a images date_sources ordered_indices
mapfile -d '' -t images < <(
  find "$input_dir" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0 | LC_ALL=C sort -z
)

((${#images[@]} > 0)) || die "No JPEG images found in: $input_dir"

manifest=$work_dir/order.tsv
: > "$manifest"

for index in "${!images[@]}"; do
  get_sort_date "${images[index]}"
  date_sources[index]=$DATE_SOURCE
  printf '%s\t%d\n' "$SORT_DATE" "$index" >> "$manifest"
done

mapfile -t ordered_indices < <(
  LC_ALL=C sort -t $'\t' -k1,1 -k2,2n "$manifest" | cut -f2
)

printf 'Found %d JPEG image(s). Target: <= 600 KiB; recompressed target: %s.\n' \
  "${#ordered_indices[@]}" "$TARGET_SIZE"

sequence=0
for index in "${ordered_indices[@]}"; do
  ((sequence += 1))
  source=${images[index]}
  source_size=$(stat -c %s -- "$source")
  output_name=$(printf 'image-%05d.jpg' "$sequence")
  staged=$work_dir/$output_name
  destination=$output_dir/$output_name

  if (( source_size <= MAX_BYTES )); then
    cp -p -- "$source" "$staged"
    action='copied unchanged'
  else
    magick "$source" -auto-orient -strip \
      -define "jpeg:extent=$TARGET_SIZE" "$staged"
    action='compressed'
  fi

  output_size=$(stat -c %s -- "$staged")
  if (( output_size > MAX_BYTES )); then
    die "$output_name is still larger than 600 KiB ($output_size bytes)."
  fi

  mv -f -- "$staged" "$destination"
  printf '[%05d/%05d] %s -> %s (%s, %s, %d bytes)\n' \
    "$sequence" "${#ordered_indices[@]}" "${source##*/}" "$output_name" \
    "$action" "${date_sources[index]}" "$output_size"
done

printf 'Done. Wrote %d ordered image(s) to %s\n' "$sequence" "$output_dir"
