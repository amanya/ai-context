# ai-context

A lightweight Bash script to gather source files from a codebase (or any directory) and concatenate them into a single context file (`ai-context.txt`) suitable for AI-driven code analysis, summarization, or other processing.

## Purpose

When working with large codebases, it can be tedious to manually collect and feed relevant files to an AI tool (like ChatGPT, Copilot, or other language models). This script automates the process by:

* Recursively finding files with specified extensions (e.g., `.cpp`, `.h`, `.go`, `.py`, etc.)
* Skipping binary files and the generated output file itself
* Concatenating all textual contents into `ai-context.txt` with clear file separators

You can then supply `ai-context.txt` directly as context to your AI of choice for tasks such as code review, documentation generation, refactoring suggestions, or automated testing assistance.

## Features

* **Extension filtering**: Use `-t` to specify a comma-separated list of file extensions (without leading dots). If you omit `-t`, the script will process all files.
* **Mandatory directory**: You must specify the target directory to scan. Running without arguments shows the usage message.
* **Binary detection**: Skips binary and non-text files to avoid corrupting the context file.
* **Output guard**: Ensures `ai-context.txt` itself is never re-included.
* **Robust bash**: Uses `set -euo pipefail` for safer scripting.

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/ai-context.git
   cd ai-context
   ```

2. Make the script executable:

   ```bash
   chmod +x aicont.sh
   ```

3. Copy to system directories:

  ```bash
  sudo install aicont.sh /usr/local/bin
  ```

## Usage

```bash
aicont.sh -t ext1,ext2,... <directory>
```

* `-t ext1,ext2,...` (optional): Comma-separated list of file extensions to include (e.g., `cpp,h,txt`).
* `<directory>` (required): Root directory to scan.

### Examples

* **Collect C++ headers and sources**

  ```bash
  aicont.sh -t cpp,h src/
  ```

* **Collect only Go files**

  ```bash
  aicont.sh -t go .
  ```

* **Collect all files**

  ```bash
  aicont.sh project/
  ```

After running, you’ll find `ai-context.txt` in your current directory, containing all the concatenated sources.
