require 'yaml'

module Viewr
  class View
    attr_reader :name, :dependencies, :sql

    def initialize(view_doc)
      @name = view_doc['name']
      @dependencies = view_doc['dependencies']
      @sql = view_doc['sql']
    end

    def self.new_from_yaml(yaml)
      new(YAML.load(yaml))
    end

    def self.new_from_yaml_file(path)
      new_from_yaml(IO.read(path))
    end

    def has_dependencies?
      !dependencies.empty?
    end

    def dependencies
      @dependencies || []
    end

    def eql?(another_view)
      self.name == another_view.name
    end

    def hash
      self.name.hash
    end
  end
end
