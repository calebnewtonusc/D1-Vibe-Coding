#!/usr/bin/env python3
"""
Post-tool-use hook: runs after Write or Edit tool calls.
- Auto-runs ESLint on edited TypeScript/JS files
- Logs what changed
"""

import json
import sys
import subprocess
import os
from datetime import datetime

LINTABLE_EXTENSIONS = {".ts", ".tsx", ".js", ".jsx", ".mjs"}

def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input", {})

    if tool_name not in ("Write", "Edit"):
        sys.exit(0)

    file_path = tool_input.get("file_path", "")
    if not file_path:
        sys.exit(0)

    _, ext = os.path.splitext(file_path)

    # Log what changed
    log_entry = f"[{datetime.now().strftime('%H:%M:%S')}] EDITED: {file_path}\n"
    try:
        with open("/tmp/claude-edits.log", "a") as f:
            f.write(log_entry)
    except Exception:
        pass

    # Auto-lint TypeScript/JS files
    if ext in LINTABLE_EXTENSIONS and os.path.isfile(file_path):
        project_dir = file_path
        while project_dir != "/" and not os.path.isfile(os.path.join(project_dir, "package.json")):
            project_dir = os.path.dirname(project_dir)

        if os.path.isfile(os.path.join(project_dir, "package.json")):
            eslint_bin = os.path.join(project_dir, "node_modules", ".bin", "eslint")
            if os.path.isfile(eslint_bin):
                try:
                    result = subprocess.run(
                        [eslint_bin, file_path, "--max-warnings", "0", "--format", "compact"],
                        cwd=project_dir,
                        capture_output=True,
                        text=True,
                        timeout=15,
                    )
                    if result.returncode != 0 and result.stdout.strip():
                        print(f"ESLint issues in {os.path.basename(file_path)}:", file=sys.stderr)
                        # Show max 10 lines of output to avoid flooding
                        lines = result.stdout.strip().split("\n")
                        for line in lines[:10]:
                            print(f"  {line}", file=sys.stderr)
                        if len(lines) > 10:
                            print(f"  ... and {len(lines) - 10} more", file=sys.stderr)
                except subprocess.TimeoutExpired:
                    pass
                except Exception:
                    pass

    sys.exit(0)

if __name__ == "__main__":
    main()
