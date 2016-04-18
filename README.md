# Viewr

[![Build Status](https://travis-ci.org/mindmatters/viewr.png)](https://travis-ci.org/mindmatters/viewr)

Viewr provides for a generic description format for SQL views and functions,
and creates or drops them, resolving dependencies on the way.

It currently has a dependency on Sequel for accessing the database to create
SQL views.

Official home: https://github.com/mindmatters/viewr

## Installation

Add this line to your application's Gemfile, adjusting the version number
as wanted:

    gem 'viewr', github: 'mindmatters/viewr', tag: 'v0.0.6'

and then execute:

    $ bundle install

## Usage

### Defining views and functions

Place YAML files containing definitions of your views and functions into two
folders, e.g. `db/views` and `db/functions` in a Rails project.

Example YAML file:

```yaml
name: view_name
dependencies:
  - some_other_view
  - some_function
sql: |
  CREATE VIEW view_name
    SELECT * FROM my_fancy_table
```

This file describes an SQL view `view_name` which depends on `some_other_view`
and `some_function`. When Viewr creates `view_name`, it will do so only after
having created `some_other_view` and `some_function`, possibly creating other
views or functions these depend on.

### Using viewr with Rails

viewr contains rake tasks automatically installed using a Railtie.

To create views and functions, run

    rake db:views:create

in a shell. To drop views and functions, run

    rake db:views:drop

That’s it.

### Using viewr without Rails

To create or drop views and functions from Ruby code, you first need to:

```ruby
    require 'viewr'
```

To issue `CREATE` statements for all defined views and functions,

```ruby
    Viewr.create_all(sequel_connection, '/path/to/view/files', '/path/to/function/files')
```

To drop all views and functions,

```ruby
    Viewr.drop_all(sequel_connection, '/path/to/view/files', '/path/to/function/files')
```

To drop all views and functions and then re-create them,

```ruby
    Viewr.recreate_all(sequel_connection, '/path/to/view/files', '/path/to/function/files')
```

It makes sense to define rake tasks which execute these statements.

## To do
- rename this project to something else (it doesn‘t do only views anymore)
- allow user to omit view of function folder
- rename class `SchemaObjectRunner`
- add Rails-specific support (through [engines](http://guides.rubyonrails.org/engines.html))
- circular dependency detection (refactor dependency resolution anyway)
- is one namespace for views and functions a wise decision?
- check whether database_adapter is Postgres-specific
- remove dependency on Sequel by using ActiveRecord.
- Change rake task names such that they cover views, functions and other db objects to come
- Add github issues for each To Do item to open them for discussion (excluding
  this one)

## Contributing

Pull requests are warmly welcome! :)
