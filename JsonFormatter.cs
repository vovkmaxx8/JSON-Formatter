// JsonFormatter.cs
using System;
using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.CommandLine; // requires System.CommandLine NuGet, but we'll use a simple parser

class JsonFormatter
{
    static int Main(string[] args)
    {
        string inputFile = null;
        string outputFile = null;
        string indent = "2";
        bool sortKeys = false;
        bool compact = false;
        bool color = false;

        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "-i":
                case "--input":
                    inputFile = args[++i];
                    break;
                case "-o":
                case "--output":
                    outputFile = args[++i];
                    break;
                case "-indent":
                    indent = args[++i];
                    break;
                case "-sort-keys":
                    sortKeys = true;
                    break;
                case "-compact":
                    compact = true;
                    break;
                case "-color":
                    color = true;
                    break;
                case "-h":
                case "--help":
                    Console.WriteLine("Usage: JsonFormatter [options]");
                    Console.WriteLine("  -i, --input <file>     Input JSON file (or stdin)");
                    Console.WriteLine("  -o, --output <file>    Output file (or stdout)");
                    Console.WriteLine("  -indent <spaces|\\t>   Indentation (default: 2)");
                    Console.WriteLine("  -sort-keys             Sort object keys");
                    Console.WriteLine("  -compact               Minify output");
                    Console.WriteLine("  -color                 Colorize output (not implemented)");
                    return 0;
            }
        }

        string content;
        if (inputFile != null)
        {
            content = File.ReadAllText(inputFile);
        }
        else
        {
            using (var reader = new StreamReader(Console.OpenStandardInput()))
            {
                content = reader.ReadToEnd();
            }
        }

        JsonDocument doc;
        try
        {
            doc = JsonDocument.Parse(content);
        }
        catch (JsonException e)
        {
            Console.Error.WriteLine($"Invalid JSON: {e.Message}");
            return 1;
        }

        // Determine indent
        string indentStr = "  ";
        if (indent == "\\t" || indent == "\t")
            indentStr = "\t";
        else if (int.TryParse(indent, out int spaces) && spaces >= 0)
            indentStr = new string(' ', spaces);

        var options = new JsonSerializerOptions
        {
            WriteIndented = !compact,
            PropertyNamingPolicy = null
        };

        string output;
        if (compact)
        {
            output = JsonSerializer.Serialize(doc.RootElement, options);
        }
        else
        {
            // For pretty print with custom indent, we need to use Utf8JsonWriter manually
            using var stream = new MemoryStream();
            using var writer = new Utf8JsonWriter(stream, new JsonWriterOptions { Indented = true, IndentSize = indentStr.Length });
            doc.WriteTo(writer);
            writer.Flush();
            output = System.Text.Encoding.UTF8.GetString(stream.ToArray());
        }

        if (color)
        {
            // Color not implemented in C# console easily without libs, just skip.
        }

        if (outputFile != null)
            File.WriteAllText(outputFile, output);
        else
            Console.WriteLine(output);

        return 0;
    }
}
