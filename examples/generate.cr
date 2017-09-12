require "../src/jq"

# [usage1]
# Print Jq.mapping definition from a json file.
#
# `cat accounts.json | crystal examples/generate_mapping.cr`
# 
# ```text
# class Foo
#   Jq.mapping({
#     name:          String  # "API McTestface"
#     business_name: String  # nil
# ```
#
# [usage2]
# Print Jq.mapping definition with full jq path from a json file.
#
# `cat accounts.json | crystal examples/generate_mapping.cr -- --full`
# 
# ```text
# class Foo
#   Jq.mapping({
#     name:          {String, ".name"         }  # "API McTestface"
#     business_name: {String, ".business_name"}  # nil
# ```
#
# [usage3]
# Print protobuf schema from a json file.
#
# `cat accounts.json | crystal examples/generate_mapping.cr -- --proto`
# 
# ```text
# message Foo {
#   optional string name           = 1;
#   optional string bissiness_name = 2;
# ```

record Field,
  name : String,
  sample : JSON::Type do

  def klass
    case sample
    when Bool   ; Bool
    when String ; String
    when Nil    ; String
    else        ; sample.class
    end
  end
end

private def extract_fields(jq, path) : Array(Field)
  jq = jq[path] if path
  case raw = jq.raw
  when Hash ; raw.map{ |k,v| Field.new(k, v)}
  else      ; abort "json(%s) expected Hash, but got %s" % [path, raw.class]
  end
end

def generate_mapping(jq, path, mode, klass)
  fields = extract_fields(jq, path)
  lines  = fields.map_with_index{|f, i|
    # max:          {Int64, ".maxDataPoints"},
    case mode
    when Mode::PROTO
      #   optional string name           = 1;
      ["optional", " ", f.klass.to_s.downcase, " ", f.name, " ", "= #{i+1};"]
    when Mode::FULL
      ["#{f.name}:", " ", "{#{f.klass}", ", ", "\"#{path}.#{f.name}\"", "}", ",  # #{f.sample.inspect}"]
    when Mode::TO_PROTO
      ["#{f.name}:", " ", "#{f.name}?,"]
    else
      ["#{f.name}:", " ", "#{f.klass}", ",  # #{f.sample.inspect}"]
    end
  }

  case mode
  when Mode::PROTO
    render_proto(lines, klass)
  when Mode::TO_PROTO
    render_to_proto(lines, klass)
  else
    render_jq(lines, klass)
  end
end

private def pretty_lines(lines : Array(Array(String)), indent : String = "") : String
  sample = lines[0]
  widths = (0...sample.size).map{|i| lines.map(&.[i].size).max}
  format = widths.map{|w| "%-#{w}s"}.join
  lines.map{|row| indent + (format % row)}.join("\n")
end

private def render_proto(lines, klass)
  String.build do |io|
    io.puts "message #{klass} {"
    io.puts pretty_lines(lines, indent: " "*2)
    io.puts "}"
  end
end

private def render_to_proto(lines, klass)
  String.build do |io|
    io.puts "class #{klass}"
    io.puts "  def to_protobuf"
    io.puts "    #{klass}.new("
    io.puts pretty_lines(lines, indent: " "*6)
    io.puts "    )"
    io.puts "  end"
    io.puts "end"
  end
end

private def render_jq(lines, klass)
  String.build do |io|
    io.puts "class #{klass}"
    io.puts "  Jq.mapping({"
    io.puts pretty_lines(lines, indent: " "*4)
    io.puts "  })"
    io.puts "end"
  end
end

enum Mode
  MAPPING
  FULL
  TO_PROTO
  PROTO
end

modes = [] of Mode
modes << Mode::FULL  if ARGV.delete("--full")
modes << Mode::PROTO if ARGV.delete("--proto")
modes << Mode::MAPPING << Mode::TO_PROTO << Mode::PROTO if ARGV.delete("--all")
modes << Mode::MAPPING if modes.empty?

path = ARGV.shift?
jq   = Jq.new(ARGF.gets_to_end)

modes.each do |mode|
  code = generate_mapping(jq: jq, path: path, mode: mode, klass: "Foo")
  puts code
end
