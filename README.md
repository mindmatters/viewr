# Viewr

[![Build Status](https://travis-ci.org/mindmatters/viewr.png)](https://travis-ci.org/mindmatters/viewr)

A Database View dependency resolver

## Installation

Add this line to your application's Gemfile:

    gem 'viewr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install viewr

## Usage

Place Yaml Files containing your view's sql in a folder.
Viewr will create views that other views depend on first.

Template yaml-File

```yaml
name: view_name
dependencies:
    - dependency_1
    - dependency_2
sql: |
    SELECT * FROM my_fancy_table
```

Example usage

```ruby
require 'viewr'

Viewr.run_views(sequel_connection, :create, '/path/to/yaml/files')
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
