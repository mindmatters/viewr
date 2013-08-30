require 'yaml'

module Viewr
  class View
    attr_reader :name, :dependency_view_names, :sql

    def initialize(view_doc)
      @name = view_doc['name']
      @dependency_view_names = view_doc['dependencies']
      @sql = view_doc['sql']
    end

    def self.new_from_yaml(yaml)
      new(YAML.load(yaml))
    end

    def self.new_from_yaml_file(path)
      new_from_yaml(IO.read(path))
    end

    def has_dependencies?
      !dependency_view_names.empty?
    end

    def dependency_view_names
      @dependency_view_names || []
    end

    def eql?(another_view)
      self.name == another_view.name
    end

    def hash
      self.name.hash
    end
  end
end

