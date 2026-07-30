#!/bin/bash
# Snake_case file renamer — recursive, handles files and dirs with spaces.
# Usage: snake_case.sh [target_directory]

set -euo pipefail
target="${1:-.}"

find "$target" -depth -name '*[[:space:]]*' -print0 | while IFS= read -r -d '' path; do
    dir=$(dirname "$path")
    old=$(basename "$path")
    # ponytail: tr for casing/spaces, one sed for the rest
    new=$(echo "$old" | tr '[:upper:]' '[:lower:]' | tr '[:space:]' '_' \
        | sed 's/[^a-z0-9._]/_/g; s/_\+/_/g; s/^_\|_$//g')
    [[ "$old" == "$new" ]] && continue
    [[ -e "$dir/$new" ]] && { echo "skip (exists): $path" >&2; continue; }
    mv "$path" "$dir/$new"
    echo "$old → $new"
done
