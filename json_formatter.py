
---

# 💻 Code Implementations

## 1. Python (`json_formatter.py`)

```python
# json_formatter.py
import sys
import json
import argparse
import os
from datetime import datetime

class JSONFormatter:
    def __init__(self, indent=2, sort_keys=False, compact=False, color=False):
        self.indent = indent if indent != '\t' else '\t'
        self.sort_keys = sort_keys
        self.compact = compact
        self.color = color
        self.colors = {
            'key': '\033[36m',      # Cyan
            'string': '\033[32m',   # Green
            'number': '\033[33m',   # Yellow
            'boolean': '\033[35m',  # Magenta
            'null': '\033[31m',     # Red
            'reset': '\033[0m'
        } if color else {}

    def format(self, data):
        if self.compact:
            return json.dumps(data, separators=(',', ':'), ensure_ascii=False)
        else:
            return json.dumps(data, indent=self.indent, sort_keys=self.sort_keys, ensure_ascii=False)

    def colorize(self, json_str):
        if not self.color:
            return json_str
        # Naive colorization (for demo)
        # We'll use a simple approach: tokenize and color
        import re
        # We'll use a basic regex to color keys, strings, etc.
        # For production, use a proper JSON tokenizer, but for demo we'll color with placeholders
        # Actually we'll just return the original string with a note
        # Simpler: use pygments if installed, but we'll avoid external deps
        # So we'll just color keys and strings roughly
        # This is not perfect but illustrative
        def color_key(match):
            return f'{self.colors["key"]}{match.group(1)}{self.colors["reset"]}'
        def color_string(match):
            return f'{self.colors["string"]}{match.group(1)}{self.colors["reset"]}'
        json_str = re.sub(r'"([^"]+)"\s*:', color_key, json_str)
        json_str = re.sub(r':\s*"([^"]*)"', lambda m: f': {self.colors["string"]}"{m.group(1)}"{self.colors["reset"]}', json_str)
        # Numbers
        json_str = re.sub(r':\s*(\d+\.?\d*)', lambda m: f': {self.colors["number"]}{m.group(1)}{self.colors["reset"]}', json_str)
        # Booleans and null
        json_str = re.sub(r':\s*(true|false)', lambda m: f': {self.colors["boolean"]}{m.group(1)}{self.colors["reset"]}', json_str)
        json_str = re.sub(r':\s*(null)', lambda m: f': {self.colors["null"]}{m.group(1)}{self.colors["reset"]}', json_str)
        return json_str

def main():
    parser = argparse.ArgumentParser(description='JSON Formatter')
    parser.add_argument('-i', '--input', help='Input JSON file (or stdin)')
    parser.add_argument('-o', '--output', help='Output file (or stdout)')
    parser.add_argument('-indent', default=2, help='Indentation spaces or \'\\t\' (default: 2)')
    parser.add_argument('-sort-keys', action='store_true', help='Sort keys alphabetically')
    parser.add_argument('-compact', action='store_true', help='Minify output')
    parser.add_argument('-color', action='store_true', help='Colorize output')
    args = parser.parse_args()

    if args.input:
        with open(args.input, 'r', encoding='utf-8') as f:
            content = f.read()
    else:
        content = sys.stdin.read()

    # Parse JSON
    try:
        data = json.loads(content)
    except json.JSONDecodeError as e:
        print(f"Invalid JSON: {e}", file=sys.stderr)
        sys.exit(1)

    # Convert indent
    indent_val = args.indent
    if indent_val == '\\t' or indent_val == '\t':
        indent_val = '\t'
    else:
        try:
            indent_val = int(indent_val)
        except:
            indent_val = 2

    formatter = JSONFormatter(indent=indent_val, sort_keys=args.sort_keys, compact=args.compact, color=args.color)
    formatted = formatter.format(data)
    if args.color:
        formatted = formatter.colorize(formatted)

    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(formatted)
    else:
        print(formatted)

if __name__ == '__main__':
    main()
