# Viewr

[![Build Status](https://travis-ci.org/mindmatters/viewr.png)](https://travis-ci.org/mindmatters/viewr)

Viewr provides for a generic description format for SQL views and functions,
and creates or drops them, resolving dependencies on the way.

It currently has a dependency on Sequel for accessing the database to create
SQL views and only works with PostgreSQL databases.

## Installation

Add this line to your application's Gemfile, adjusting the version number
as wanted:

    gem 'viewr', github: 'mindmatters/viewr', tag: 'v0.0.6'

and then execute:

    $ bundle install

## Usage

Place YAML Files containing descriptions of your views and functions into two
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

To create or drop views and functions, you first need to:

```ruby
    require 'viewr'
```

To issue `CREATE` statements for all defined views and functions,

```ruby
    Viewr.create_all(sequel_database_object, '/path/to/view/files', '/path/to/function/files')
```

To drop all views and functions,

```ruby
    Viewr.drop_all(sequel_database_object, '/path/to/view/files', '/path/to/function/files')
```

To drop all views and functions and then re-create them,

```ruby
    Viewr.recreate_all(sequel_database_object, '/path/to/view/files', '/path/to/function/files')
```

It makes sense to define rake tasks which execute these statements.

## Contributing

Pull requests are warmly welcome! :)
