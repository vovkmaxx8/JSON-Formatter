// json_formatter.js
const fs = require('fs');
const path = require('path');

function showHelp() {
    console.log(`Usage: node json_formatter.js [options]
Options:
  -i, --input <file>     Input JSON file (or stdin)
  -o, --output <file>    Output file (or stdout)
  -indent <spaces|\\t>   Indentation (default: 2)
  -sort-keys             Sort object keys
  -compact               Minify output
  -color                 Colorize output (basic)
  -h, --help             Show this help`);
}

function colorize(jsonStr) {
    // Very basic colorization for demo
    const colors = {
        key: '\x1b[36m',
        string: '\x1b[32m',
        number: '\x1b[33m',
        boolean: '\x1b[35m',
        null: '\x1b[31m',
        reset: '\x1b[0m'
    };
    // Not a full tokenizer, but simple replacements
    let result = jsonStr;
    result = result.replace(/"([^"]+)"\s*:/g, `${colors.key}"$1"${colors.reset}:`);
    result = result.replace(/:\s*"([^"]*)"/g, `: ${colors.string}"$1"${colors.reset}`);
    result = result.replace(/:\s*(\d+\.?\d*)/g, `: ${colors.number}$1${colors.reset}`);
    result = result.replace(/:\s*(true|false)/g, `: ${colors.boolean}$1${colors.reset}`);
    result = result.replace(/:\s*(null)/g, `: ${colors.null}$1${colors.reset}`);
    return result;
}

function main() {
    const args = process.argv.slice(2);
    let inputFile = null, outputFile = null;
    let indent = 2, sortKeys = false, compact = false, color = false;

    for (let i = 0; i < args.length; i++) {
        const arg = args[i];
        if (arg === '-i' || arg === '--input') {
            inputFile = args[++i];
        } else if (arg === '-o' || arg === '--output') {
            outputFile = args[++i];
        } else if (arg === '-indent') {
            const val = args[++i];
            if (val === '\\t' || val === '\t') indent = '\t';
            else indent = parseInt(val, 10) || 2;
        } else if (arg === '-sort-keys') {
            sortKeys = true;
        } else if (arg === '-compact') {
            compact = true;
        } else if (arg === '-color') {
            color = true;
        } else if (arg === '-h' || arg === '--help') {
            showHelp();
            process.exit(0);
        }
    }

    let inputData = '';
    if (inputFile) {
        try {
            inputData = fs.readFileSync(inputFile, 'utf8');
        } catch (e) {
            console.error(`Error reading file: ${e.message}`);
            process.exit(1);
        }
    } else {
        // read stdin
        inputData = fs.readFileSync(0, 'utf8'); // works in Node
    }

    let parsed;
    try {
        parsed = JSON.parse(inputData);
    } catch (e) {
        console.error(`Invalid JSON: ${e.message}`);
        process.exit(1);
    }

    let output;
    if (compact) {
        output = JSON.stringify(parsed);
    } else {
        let space = typeof indent === 'number' ? indent : indent;
        output = JSON.stringify(parsed, sortKeys ? Object.keys(parsed).sort() : null, space);
    }

    if (color) {
        output = colorize(output);
    }

    if (outputFile) {
        try {
            fs.writeFileSync(outputFile, output, 'utf8');
        } catch (e) {
            console.error(`Error writing file: ${e.message}`);
            process.exit(1);
        }
    } else {
        console.log(output);
    }
}

main();
