#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -t ext1,ext2,... [-s dir1,dir2,...] <directory>"
  echo
  echo "  -t    comma-separated list of file extensions to include (no leading dots)."
  echo "        e.g. \"cpp,h,txt\""
  echo "  -s    comma-separated list of subdirectory paths (relative to root) to exclude."
  echo "  directory  root directory to search (required)."
  exit 1
}

types=()
exclude_subdirs=()

# Parse options
while getopts ":t:s:" opt; do
  case $opt in
    t)
      IFS=',' read -r -a types <<< "$OPTARG"
      ;;
    s)
      IFS=',' read -r -a dirs <<< "$OPTARG"
      exclude_subdirs+=("${dirs[@]}")
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

# Check directory argument
if [ $# -lt 1 ]; then
  echo "Error: <directory> is required." >&2
  usage
fi
start_dir="$1"

if [ ! -d "$start_dir" ]; then
  echo "Error: directory '$start_dir' does not exist." >&2
  exit 1
fi

output_file="ai-context.txt"
> "$output_file"

# Start building find expression
find_expr=(find "$start_dir" -type f ! -name "$output_file")

# Add exclusions for subdirectories
for subdir in "${exclude_subdirs[@]}"; do
  full_path="$start_dir/$subdir"
  find_expr+=( ! -path "$full_path/*" )
done

# Add extension filtering
if [ ${#types[@]} -gt 0 ]; then
  find_expr+=( \( )
  for i in "${!types[@]}"; do
    ext="${types[i]#\.}"
    find_expr+=( -iname "*.${ext}" )
    if [ $i -lt $(( ${#types[@]} - 1 )) ]; then
      find_expr+=( -o )
    fi
  done
  find_expr+=( \) )
fi

# Run find and process files
"${find_expr[@]}" | while IFS= read -r file; do
  if ! grep -Iq . "$file"; then
    continue
  fi
  printf "\n===== %s =====\n\n" "$file" >> "$output_file"
  cat "$file" >> "$output_file"
done

echo "Concatenation completed. Output saved to $output_file"
