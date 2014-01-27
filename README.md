# Viewr

[![Build Status](https://travis-ci.org/mindmatters/viewr.png)](https://travis-ci.org/mindmatters/viewr)

Viewr provides for a generic description format for SQL views and functions,
and creates or drops them, resolving dependencies on the way.

## Installation

Add this line to your application's Gemfile:

    gem 'viewr'

And then execute:

    $ bundle install

Or install it system-wide:

    $ gem install viewr

## Usage

Place YAML Files containing descriptions of your views and functions into a
folder, e.g. `db/views` and `db/functions` in a Rails project.

Example YAML file:

```yaml
name: view_name
dependencies:
    - some_other_view
    - some_function
sql: |
    SELECT * FROM my_fancy_table
```

This file describes an SQL view `view_name` which depends on `some_other_view`
and `some_function`. When Viewr creates `view_name`, it will do so only after
it has created `some_other_view` and `some_function`, possibly creating other
views or functions these depend on.

Example usage:

```ruby
require 'viewr'

Viewr.create_all(sequel_connection, '/path/to/view/files', '/path/to/function/files')
```

In all examples you need to

```ruby
    require 'viewr'
```

To issue `CREATE` statements for all given views and functions:

```ruby
    Viewr.create_all(sequel_connection, '/path/to/view/files', '/path/to/function/files')
```

To drop all views and functions:

```ruby
    Viewr.drop_all(sequel_connection, '/path/to/view/files', '/path/to/function/files')
```

To drop all views and functions and then re-create them:

```ruby
    Viewr.recreate_all(sequel_connection, '/path/to/view/files', '/path/to/function/files')
```

## To do
- rename this project to `squealer`
- rename class `SchemaObjectRunner`
- circular dependency detection (refactor dependency resolution anyway)
- is one namespace for views and functions a wise decision?
- check whether database_adapter is Postgres-specific.

## Contributing

Pull requests are warmly welcome! :)
