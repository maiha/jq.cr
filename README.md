# jq.cr [![Build Status](https://travis-ci.org/maiha/jq.cr.svg?branch=master)](https://travis-ci.org/maiha/jq.cr)

thin JSON::Any wrapper to emulate jq for [Crystal](http://crystal-lang.org/).

- crystal: 0.20.4 or higher (use v0.4.0 or higher)
- crystal: 0.20.3 or lower (use v0.3.1)

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

- looks like `JSON.mapping` except this requires Tuple(type, json_path, (time_format)) for its arg.
- NOTE: use `Int64` rather than `Int32` for Integer

```crystal
require "jq"

class Request
  Jq.mapping({
    from:    {Time, ".range.from", "%FT%T.%LZ"},
    targets: {Array(String), ".targets[].target"},
    format:  String,
    max:     {Int64, ".maxDataPoints"},
  })
end

req = Request.from_json(str)
req.from     # => Time.new(2016,9,2,13,32,9,981)
req.targets  # => ["cpu","mem"]
req.format   # => "json"
req.max      # => 1299

req = Request.from_json("{}")
req.max      # Jq::NotFound(key: "max")
req.max?     # => nil
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

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  jq:
    github: maiha/jq.cr
    version: 0.3.1
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

