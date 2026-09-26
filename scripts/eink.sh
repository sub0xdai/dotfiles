#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="./eink_4k_output"
mkdir -p "$OUT_DIR"

# Enable case-insensitive globbing for file extensions
shopt -s nullglob nocaseglob
FILES=( *.jpg *.jpeg *.png )

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No matching image files found in the current directory."
    exit 1
fi

echo "Processing ${#FILES[@]} images..."

export OUT_DIR

# Process files concurrently across all CPU cores
printf "%s\0" "${FILES[@]}" | xargs -0 -P "$(nproc)" -I {} bash -c '
    input="$1"
    base=$(basename "$input")
    filename="${base%.*}"
    output="$OUT_DIR/${filename}_eink.png"

    # Avoid reprocessing if output file exists
    if [ -f "$output" ]; then
        exit 0
    fi

    magick "$input" \
        -resize 3840x2160^ \
        -gravity center \
        -extent 3840x2160 \
        -colorspace Gray \
        -brightness-contrast 10x20 \
        -ordered-dither o8x8,16 \
        "$output"
' _ {}

echo "Finished. Converted images are in: $OUT_DIR"
