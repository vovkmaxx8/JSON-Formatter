# 🧹 JSON Formatter – Multi‑Language Edition

A powerful **JSON formatter and validator** that pretty‑prints, minifies, validates, and color‑highlights JSON data.  
Supports reading from files or standard input, custom indentation, key sorting, and compact output.  
Built in **7 programming languages** – perfect for developers, testers, and automation pipelines.

## ✨ Features
- **Pretty‑print** – formats JSON with configurable indentation (spaces or tabs).
- **Minify** – removes all unnecessary whitespace for compact storage.
- **Validate** – checks JSON syntax and reports errors with line/column details.
- **Sort keys** – sorts object keys alphabetically for consistent output.
- **Color output** – syntax highlights JSON in the terminal (where supported).
- **Read from file or stdin** – works in both batch and interactive modes.
- **Write to file** – optionally save formatted JSON to an output file.
- **Custom indent** – specify number of spaces or use `\t` for tabs.

## 🗂 Languages & Files
| Language          | File                  |
|-------------------|-----------------------|
| Python            | `json_formatter.py`   |
| Go                | `json_formatter.go`   |
| JavaScript        | `json_formatter.js`   |
| C#                | `JsonFormatter.cs`    |
| Java              | `JsonFormatter.java`  |
| Ruby              | `json_formatter.rb`   |
| Swift             | `json_formatter.swift`|

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler:

| Language | Command |
|----------|---------|
| Python   | `python json_formatter.py -i input.json -o output.json -indent 2` |
| Go       | `go run json_formatter.go -input input.json -output output.json -indent 2` |
| JavaScript | `node json_formatter.js -i input.json -o output.json -indent 2` |
| C#       | `dotnet run -- -i input.json -o output.json -indent 2` (or compile and run `JsonFormatter.exe -i input.json ...`) |
| Java     | `javac JsonFormatter.java && java JsonFormatter -i input.json -o output.json -indent 2` |
| Ruby     | `ruby json_formatter.rb -i input.json -o output.json -indent 2` |
| Swift    | `swift json_formatter.swift -i input.json -o output.json -indent 2` |

If no input file is specified, the program reads from stdin.  
If no output file is specified, the result is printed to stdout.

## 📊 Example
**Input (minified):**
```json
{"name":"John","age":30,"cars":["Ford","BMW","Fiat"]}
Output (formatted with 2 spaces):

json
{
  "name": "John",
  "age": 30,
  "cars": [
    "Ford",
    "BMW",
    "Fiat"
  ]
}
Minified output:

json
{"name":"John","age":30,"cars":["Ford","BMW","Fiat"]}
🔧 Command‑line Options (Common)
Option	Description
-i, --input	Input JSON file (default: stdin)
-o, --output	Output file (default: stdout)
-indent	Number of spaces or \t for indentation (default: 2)
-sort-keys	Sort object keys alphabetically
-compact	Output minified JSON (no extra spaces)
-color	Enable color highlighting (if terminal supports)
-h, --help	Show help message
🤝 Contributing
Add support for JSON5, streaming large files, or JSON schema validation – PRs welcome!

📜 License
MIT – use freely.
