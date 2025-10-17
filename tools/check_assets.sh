#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  set -- "Puzzle/images" "Puzzle Map Makers/images"
fi

# List of image paths (without extension) that intentionally omit high-resolution variants.
WHITELIST=(
  "Puzzle Map Makers/images/cursor"
  "Puzzle Map Makers/images/delete"
)

missing=0
for dir in "$@"; do
  if [[ ! -d "$dir" ]]; then
    printf '[assets] Skipping missing directory: %s\n' "$dir" >&2
    continue
  fi

  while IFS= read -r -d '' image; do
    filename=$(basename "$image")
    [[ $filename == *@* ]] && continue

    base="${image%.*}"
    ext="${image##*.}"

    skip=0
    for entry in "${WHITELIST[@]}"; do
      if [[ "$base" == "$entry" ]]; then
        skip=1
        break
      fi
    done
    [[ $skip -eq 1 ]] && continue

    for suffix in "@2x" "@4x"; do
      if [[ ! -f "${base}${suffix}.${ext}" ]]; then
        printf '[assets] Missing %s%s.%s\n' "$base" "$suffix" "$ext" >&2
        missing=1
      fi
    done
  done < <(find "$dir" -maxdepth 1 -type f -name '*.png' -print0)
done

exit $missing
