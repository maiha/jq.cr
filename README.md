# jq.cr [![Build Status](https://travis-ci.org/maiha/jq.cr.svg?branch=master)](https://travis-ci.org/maiha/jq.cr)

thin JSON::Any wrapper to emulate jq for [Crystal](http://crystal-lang.org/).

see [Wiki](https://github.com/maiha/jq.cr/wiki) for examples

#### breaking changes
- v0.5.0 : **(breaking-change)** mapping: parse `Time` without formats.

#### crystal versions
- v0.5.1 : 0.24 or lower
- v0.6.0 : 0.25 .. 0.27
- v0.8.0 : 0.27 .. 0.35
- v0.9.0 : 0.36

## Usage

- For example, here is a Grafana request data.

```json
{
  "panelId":1,
  "range":{"from":"2016-09-02T13:32:09.981Z","to":"2016-09-02T14:17:34.306Z"},
  "rangeRaw":{"from":"2016-09-02T13:32:09.981Z","to":"2016-09-02T14:17:34.306Z"},
  "interval":"2s",
  "targets":[{"target":"cpu","refId":"A"},{"target":"mem","refId":"B"}],
  "format":"json",
  "maxDataPoints":1299
}
```

### Parse in Functional way

- Just call 'Jq#[]` with query path.

```crystal
require "jq"

jq = Jq.new(str)
jq[".range.from"].as_s       # => "2016-09-02T13:32:09.981Z"
jq[".targets[].target"].as_a # => ["cpu","mem"]
jq[".format"].as_s           # => "json"
jq[".maxDataPoints"].as_i    # => 1299
jq[".xxx"]                   # Jq::NotFound("`.xxx' Missing hash key: "xxx")
jq[".xxx"]?                  # => nil
```

- See `spec/fixtures/*` files for further usage, or try `crystal spec -v` for full features

### Auto parsing and casting by `mapping`

- looks like `JSON.mapping` except this requires Tuple(type, json_path) for its arg.
- NOTE: use `Int64` rather than `Int32` for Integer

```crystal
require "jq"

class Request
  Jq.mapping({
    from:    {Time, ".range.from"},
    targets: {Array(String), ".targets[].target"},
    format:  String,
    max:     {Int64, ".maxDataPoints"},
  })
end

req = Request.from_json(str)
req.from        # => Time.new(2016,9,2,13,32,9,981)
req.targets     # => ["cpu","mem"]
req.format      # => "json"
req.max         # => 1299
req.to_h["max"] # => 1299

req = Request.from_json("{}")
req.max         # Jq::NotFound(key: "max")
req.max?        # => nil
```

#### default value

- override `default_XXX` to customize the behaviour of missing `XXX`

```crystal
require "jq"

class User
  Jq.mapping({
    name: String,
  })

  def default_name
    "(no name)"
  end
end

user = User.from_json("{}")
user.name    # => "(no name)"
```

#### custom builder

- override `build_XXX(jq : Jq, hint : String)` to customize the behaviour of building `XXX`

Imagine a strange API that returns a `String` if null, regardless of the value of `Int` type.

```json
[
  {"id": 1, "value": 10},
  {"id": 2, "value": "--"}
]
```

In this case, you can write your own logic to accept it by overriding `build_count`.


```crystal
class Report
  Jq.mapping({
    id: Int32,
    count: Int32?,
  })

  def build_count(jq : Jq, hint : String)
    case jq.raw
    when "--"
      nil
    else
      jq.cast(Int32, hint)
    end
  end
end

reports = Array(Report).from_json <<-EOF
  [
    {"id": 1, "count": 10},
    {"id": 2, "count": "--"}
  ]
  EOF
reports.map(&.count?) # => [10, nil]
```

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  jq:
    github: maiha/jq.cr
    version: 0.9.0
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

