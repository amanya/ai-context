#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -t ext1,ext2,... <directory>"
  echo
  echo "  -t    comma-separated list of file extensions to include (no leading dots)."
  echo "        e.g. \"cpp,h,txt\""
  echo "  directory  root directory to search (required)."
  exit 1
}

# At least one arg (the directory) is required
if [ $# -eq 0 ]; then
  usage
fi

# Default: no type filter
types=()

# Parse options
while getopts ":t:" opt; do
  case $opt in
    t)
      IFS=',' read -r -a types <<< "$OPTARG"
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done
shift $((OPTIND -1))

# Now the directory is mandatory
if [ $# -lt 1 ]; then
  echo "Error: <directory> is required." >&2
  usage
fi
start_dir="$1"

# Verify start_dir exists
if [ ! -d "$start_dir" ]; then
  echo "Error: directory '$start_dir' does not exist." >&2
  exit 1
fi

output_file="ai-context.txt"
> "$output_file"

# Build the find command, excluding the output file itself
find_expr=(find "$start_dir" -type f ! -name "$output_file")

if [ ${#types[@]} -gt 0 ]; then
  find_expr+=( \( )
  for i in "${!types[@]}"; do
    ext="${types[i]#\.}"            # strip any leading dot
    find_expr+=( -iname "*.${ext}" )
    if [ $i -lt $(( ${#types[@]} - 1 )) ]; then
      find_expr+=( -o )
    fi
  done
  find_expr+=( \) )
fi

# Execute find; skip binaries in the loop
"${find_expr[@]}" | while IFS= read -r file; do
  # skip binary files
  if ! grep -Iq . "$file"; then
    continue
  fi

  printf "\n===== %s =====\n\n" "$file" >> "$output_file"
  cat "$file" >> "$output_file"
done

echo "Concatenation completed. Output saved to $output_file"
