// json_formatter.go
package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

func main() {
	inputFile := flag.String("i", "", "Input JSON file (or stdin)")
	outputFile := flag.String("o", "", "Output file (or stdout)")
	indent := flag.String("indent", "2", "Indentation spaces or '\\t'")
	sortKeys := flag.Bool("sort-keys", false, "Sort keys alphabetically")
	compact := flag.Bool("compact", false, "Minify output")
	color := flag.Bool("color", false, "Colorize output (not supported in Go)")

	flag.Parse()

	var data []byte
	if *inputFile != "" {
		var err error
		data, err = ioutil.ReadFile(*inputFile)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error reading file: %v\n", err)
			os.Exit(1)
		}
	} else {
		stat, _ := os.Stdin.Stat()
		if (stat.Mode() & os.ModeCharDevice) != 0 {
			fmt.Fprintln(os.Stderr, "No input provided.")
			os.Exit(1)
		}
		var err error
		data, err = ioutil.ReadAll(os.Stdin)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error reading stdin: %v\n", err)
			os.Exit(1)
		}
	}

	// Parse JSON
	var obj interface{}
	if err := json.Unmarshal(data, &obj); err != nil {
		fmt.Fprintf(os.Stderr, "Invalid JSON: %v\n", err)
		os.Exit(1)
	}

	// Determine indentation
	var indentStr string
	if *indent == "\\t" || *indent == "\t" {
		indentStr = "\t"
	} else {
		// default to 2 spaces
		indentStr = strings.Repeat(" ", 2)
		// try to parse as int for custom spaces
		var spaces int
		if _, err := fmt.Sscan(*indent, &spaces); err == nil && spaces >= 0 {
			indentStr = strings.Repeat(" ", spaces)
		}
	}

	var out []byte
	var err error
	if *compact {
		out, err = json.Marshal(obj)
	} else {
		out, err = json.MarshalIndent(obj, "", indentStr)
	}
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error formatting: %v\n", err)
		os.Exit(1)
	}

	if *outputFile != "" {
		err = ioutil.WriteFile(*outputFile, out, 0644)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error writing output: %v\n", err)
			os.Exit(1)
		}
	} else {
		fmt.Println(string(out))
	}
}
