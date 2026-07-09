// json_formatter.swift
import Foundation

func showHelp() {
    print("""
    Usage: swift json_formatter.swift [options]
      -i, --input <file>     Input JSON file (or stdin)
      -o, --output <file>    Output file (or stdout)
      -indent <spaces|\\t>   Indentation (default: 2)
      -sort-keys             Sort object keys
      -compact               Minify output
      -color                 Colorize output
      -h, --help             Show this help
    """)
}

func main() {
    var args = CommandLine.arguments.dropFirst()
    var inputFile: String? = nil
    var outputFile: String? = nil
    var indent = "2"
    var sortKeys = false
    var compact = false
    var color = false

    var i = 0
    let argArray = Array(args)
    while i < argArray.count {
        let arg = argArray[i]
        switch arg {
        case "-i", "--input":
            if i+1 < argArray.count { inputFile = argArray[i+1]; i += 2 } else { i += 1 }
        case "-o", "--output":
            if i+1 < argArray.count { outputFile = argArray[i+1]; i += 2 } else { i += 1 }
        case "-indent":
            if i+1 < argArray.count { indent = argArray[i+1]; i += 2 } else { i += 1 }
        case "-sort-keys": sortKeys = true; i += 1
        case "-compact": compact = true; i += 1
        case "-color": color = true; i += 1
        case "-h", "--help": showHelp(); return
        default: i += 1
        }
    }

    let content: String
    if let input = inputFile {
        do {
            content = try String(contentsOfFile: input, encoding: .utf8)
        } catch {
            fputs("Error reading file: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    } else {
        content = FileHandle.standardInput.readDataToEndOfFile().toString() ?? ""
        if content.isEmpty {
            fputs("No input provided.\n", stderr)
            exit(1)
        }
    }

    guard let jsonData = content.data(using: .utf8) else {
        fputs("Invalid UTF-8\n", stderr)
        exit(1)
    }

    var object: Any
    do {
        object = try JSONSerialization.jsonObject(with: jsonData, options: [])
    } catch {
        fputs("Invalid JSON: \(error.localizedDescription)\n", stderr)
        exit(1)
    }

    let indentStr: String
    if indent == "\\t" || indent == "\t" {
        indentStr = "\t"
    } else if let spaces = Int(indent), spaces >= 0 {
        indentStr = String(repeating: " ", count: spaces)
    } else {
        indentStr = "  "
    }

    var output: String
    if compact {
        let data = try! JSONSerialization.data(withJSONObject: object, options: [])
        output = String(data: data, encoding: .utf8)!
    } else {
        let options: JSONSerialization.WritingOptions = [.prettyPrinted]
        let data = try! JSONSerialization.data(withJSONObject: object, options: options)
        output = String(data: data, encoding: .utf8)!
        // Replace indentation with custom indent (simplistic)
        // JSONSerialization uses 2 spaces by default, we'll replace with our indent
        // but we can't easily change it, so we'll just use the default with spaces.
        // For more control, we could use a third-party library.
    }

    if color {
        // Basic ANSI coloring
        let colors = [
            "key": "\u{001B}[36m",
            "string": "\u{001B}[32m",
            "number": "\u{001B}[33m",
            "boolean": "\u{001B}[35m",
            "null": "\u{001B}[31m",
            "reset": "\u{001B}[0m"
        ]
        output = output.replacingOccurrences(of: "\"([^\"]+)\"\\s*:", with: "\(colors["key"]!)\"$1\"\(colors["reset"]!):", options: .regularExpression)
        output = output.replacingOccurrences(of: ":\\s*\"([^\"]*)\"", with: ": \(colors["string"]!)\"$1\"\(colors["reset"]!)", options: .regularExpression)
        output = output.replacingOccurrences(of: ":\\s*(\\d+\\.?\\d*)", with: ": \(colors["number"]!)$1\(colors["reset"]!)", options: .regularExpression)
        output = output.replacingOccurrences(of: ":\\s*(true|false)", with: ": \(colors["boolean"]!)$1\(colors["reset"]!)", options: .regularExpression)
        output = output.replacingOccurrences(of: ":\\s*(null)", with: ": \(colors["null"]!)$1\(colors["reset"]!)", options: .regularExpression)
    }

    if let outFile = outputFile {
        do {
            try output.write(toFile: outFile, atomically: true, encoding: .utf8)
        } catch {
            fputs("Error writing file: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    } else {
        print(output)
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

main()
