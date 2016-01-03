# jq.cr

thin JSON::Any wrapper to emulate jq for crystal
[![Build Status](https://travis-ci.org/maiha/jq.cr.svg?branch=master)](https://travis-ci.org/maiha/jq.cr)

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  jq:
    github: maiha/jq.cr
```

And then, run `crystal deps`


## Usage

#### query

```crystal
require "jq"

str = %({"name": "Hi", "any": [{"x": 1}, 2, "hey", true, false, 1.5, null]})
q = Jq.new(str)
q[".name"].raw        # => "Hi"
q[".any[1]"].raw      # => 2
q[".any"]             # => #<Jq:0x10bb090 @any=[{"x" => 1}, 2, "hey", true, false, 1.5, nil], @trace=".any">
q[".any[1]"]          # => #<Jq:0xf76c00 @any=2, @trace=".any[1]">
q[".any"]["[1]"]      # => #<Jq:0xcd3ba0 @any=2, @trace=".any[1]">
q[".any"]["[1]"].raw  # => 2
q[".any[0].x"].raw    # => 1
q[".foo"]             # raises 'Missing hash key: "foo"' (TODO: this should return null???)
```

- see `spec/fixtures/*` files, or try `crystal spec -v` for full features

#### mapping

- provides attributes as same as `JSON.mapping` except this requires JSON path
- ATTR SYNTAX: key=ATTR_NAME, val=Tuple(type: Class, path: String)
- NOTE: use `Int64` rather than `Int32` for Integer

```crystal
require "jq"

class Foo
  Jq.mapping({
    name:  {String, ".name"},
    count: {Int64, ".any[1]"},
    x:     {Int64, ".any[0].x"},
  })
end

str = %({"name": "Hi", "any": [{"x": 1}, 2, "hey", true, false, 1.5, null]})
foo = Foo.from_json(str)
foo.name   # => "Hi"
foo.count  # => 2
foo.x      # => 1
```

## Development

```shell
cd jq.cr
crystal deps   # install dependencies
crystal spec   # run specs
```

## Contributing

1. Fork it ( https://github.com/maiha/jq.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

