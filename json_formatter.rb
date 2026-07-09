# json_formatter.rb
require 'json'
require 'optparse'

options = {
  input: nil,
  output: nil,
  indent: 2,
  sort_keys: false,
  compact: false,
  color: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby json_formatter.rb [options]"
  opts.on("-iFILE", "--input=FILE", "Input JSON file (or stdin)") { |f| options[:input] = f }
  opts.on("-oFILE", "--output=FILE", "Output file (or stdout)") { |f| options[:output] = f }
  opts.on("-indentVAL", "Indentation spaces or '\\t' (default: 2)") { |v| options[:indent] = v }
  opts.on("--sort-keys", "Sort keys alphabetically") { options[:sort_keys] = true }
  opts.on("--compact", "Minify output") { options[:compact] = true }
  opts.on("--color", "Colorize output") { options[:color] = true }
  opts.on("-h", "--help", "Show help") { puts opts; exit }
end.parse!

content = if options[:input]
            File.read(options[:input], encoding: 'utf-8')
          else
            $stdin.read
          end

begin
  data = JSON.parse(content)
rescue JSON::ParserError => e
  $stderr.puts "Invalid JSON: #{e.message}"
  exit 1
end

indent = options[:indent]
if indent == "\\t" || indent == "\t"
  indent = "\t"
else
  indent = indent.to_i rescue 2
end

output = if options[:compact]
           JSON.generate(data, options: {})
         else
           JSON.pretty_generate(data, indent: indent, object_nl: "\n", array_nl: "\n", 
                               space: " ", space_before: "", sort_keys: options[:sort_keys])
         end

if options[:color]
  # Simple ANSI coloring
  output.gsub!(/"([^"]+)"\s*:/, "\e[36m\"\\1\"\e[0m:")
  output.gsub!(/:\s*"([^"]*)"/, ': \e[32m"\1"\e[0m')
  output.gsub!(/:\s*(\d+\.?\d*)/, ': \e[33m\1\e[0m')
  output.gsub!(/:\s*(true|false)/, ': \e[35m\1\e[0m')
  output.gsub!(/:\s*(null)/, ': \e[31m\1\e[0m')
end

if options[:output]
  File.write(options[:output], output)
else
  puts output
end
