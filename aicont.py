#!/usr/bin/env python3
import argparse
import os
from pathlib import Path

def is_text_file(filepath):
    try:
        with open(filepath, 'rb') as f:
            chunk = f.read(1024)
            if b'\0' in chunk:
                return False
        return True
    except Exception:
        return False

def main():
    parser = argparse.ArgumentParser(
        description="Concatenate text files from a directory tree, filtering by extension and excluding subdirectories."
    )
    parser.add_argument("-t", "--types", help="Comma-separated list of file extensions to include (e.g. cpp,h,txt)")
    parser.add_argument("-s", "--exclude", help="Comma-separated list of subdirectories (relative to root) to exclude")
    parser.add_argument("directory", help="Root directory to search")

    args = parser.parse_args()
    root_dir = Path(args.directory).resolve()

    if not root_dir.is_dir():
        print(f"Error: directory '{root_dir}' does not exist.")
        exit(1)

    types = set()
    if args.types:
        types = {ext.strip().lstrip('.') for ext in args.types.split(',')}

    excluded_paths = set()
    if args.exclude:
        for subdir in args.exclude.split(','):
            path = (root_dir / subdir.strip()).resolve()
            excluded_paths.add(path)

    output_file = root_dir / "ai-context.txt"
    with open(output_file, 'w', encoding='utf-8') as out:
        for path in root_dir.rglob("*"):
            if not path.is_file():
                continue

            # Skip output file itself
            if path.resolve() == output_file:
                continue

            # Skip excluded directories
            if any(str(path).startswith(str(ex)) for ex in excluded_paths):
                continue

            # Filter by extension
            if types and path.suffix.lstrip('.').lower() not in types:
                continue

            if not is_text_file(path):
                continue

            rel_path = path.relative_to(root_dir)
            out.write(f"\n===== {rel_path} =====\n\n")
            try:
                content = path.read_text(encoding='utf-8', errors='replace')
                out.write(content)
            except Exception as e:
                print(f"Skipping {path} due to error: {e}")

    print(f"Concatenation completed. Output saved to {output_file}")

if __name__ == "__main__":
    main()
