#!/bin/bash
set -e

# Creates docs/ideas/ for a saved /grill one-pager (divergent mode).
# Run only after the user has asked to save the one-pager.

IDEAS_DIR="${1:-docs/ideas}"

if [ ! -d "$IDEAS_DIR" ]; then
  mkdir -p "$IDEAS_DIR"
  echo "Created directory: $IDEAS_DIR" >&2
else
  echo "Directory already exists: $IDEAS_DIR" >&2
fi

echo "{\"status\": \"ready\", \"directory\": \"$IDEAS_DIR\"}"
