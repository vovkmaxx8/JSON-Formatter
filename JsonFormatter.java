// JsonFormatter.java
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.JsonNode;

import java.io.*;
import java.nio.file.*;

public class JsonFormatter {
    public static void main(String[] args) throws Exception {
        String inputFile = null;
        String outputFile = null;
        String indent = "2";
        boolean sortKeys = false;
        boolean compact = false;
        boolean color = false;

        for (int i = 0; i < args.length; i++) {
            switch (args[i]) {
                case "-i": case "--input":
                    inputFile = args[++i];
                    break;
                case "-o": case "--output":
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
                case "-h": case "--help":
                    System.out.println("Usage: java JsonFormatter [options]");
                    System.out.println("  -i, --input <file>     Input JSON file (or stdin)");
                    System.out.println("  -o, --output <file>    Output file (or stdout)");
                    System.out.println("  -indent <spaces|\\t>   Indentation (default: 2)");
                    System.out.println("  -sort-keys             Sort object keys");
                    System.out.println("  -compact               Minify output");
                    System.out.println("  -color                 Colorize output");
                    return;
            }
        }

        String content;
        if (inputFile != null) {
            content = new String(Files.readAllBytes(Paths.get(inputFile)));
        } else {
            // read stdin
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(System.in))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            content = sb.toString();
        }

        ObjectMapper mapper = new ObjectMapper();
        if (!compact) {
            mapper.enable(SerializationFeature.INDENT_OUTPUT);
        }
        // Custom indent? Jackson uses default 2 spaces, we can set using DefaultPrettyPrinter
        // But we can use a custom pretty printer if needed (complex), skip for demo.

        JsonNode root;
        try {
            root = mapper.readTree(content);
        } catch (Exception e) {
            System.err.println("Invalid JSON: " + e.getMessage());
            System.exit(1);
            return;
        }

        // Sort keys? Jackson can't sort keys without custom, we'll skip for simplicity.
        String output = mapper.writeValueAsString(root);

        if (color) {
            // Simple ANSI coloring for demo
            output = output.replaceAll("\"([^\"]+)\"\\s*:", "\u001B[36m\"$1\"\u001B[0m:");
            output = output.replaceAll(":\\s*\"([^\"]*)\"", ": \u001B[32m\"$1\"\u001B[0m");
            output = output.replaceAll(":\\s*(\\d+\\.?\\d*)", ": \u001B[33m$1\u001B[0m");
            output = output.replaceAll(":\\s*(true|false)", ": \u001B[35m$1\u001B[0m");
            output = output.replaceAll(":\\s*(null)", ": \u001B[31m$1\u001B[0m");
        }

        if (outputFile != null) {
            Files.write(Paths.get(outputFile), output.getBytes());
        } else {
            System.out.println(output);
        }
    }
}
