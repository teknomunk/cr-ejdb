# ejdb

This is a Crystal binding for the Embedded JSON Database (EJDB) library.  EJDB is to mongodb, what sqlite is to MySQL. 
No server is required to use.

## Installation

Ensure that EJDB is installed on the system. This shard does not include the EJDB libraries.

Add this to your application's `shard.yml`:

```yaml
dependencies:
  ejdb:
    github: teknomunk/cr-ejdb
```

## Usage

```crystal
require "ejdb"
```

## Contributing

1. Fork it (<https://github.com/teknomunk/cr-ejdb/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [teknomunk](https://github.com/teknomunk) teknomunk - creator, maintainer
