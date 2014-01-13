require 'yaml'

module Viewr
  class Function
    attr_reader :name, :dependencies, :sql

    def initialize(function_doc)
      @name = function_doc['name']
      @dependencies = function_doc['dependencies']
      @arguments = function_doc['arguments']
      @returns = function_doc['returns']

      @sql = function_doc['sql']
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

    def eql?(another_function)
      self.name == another_function.name
    end

    def hash
      self.name.hash
    end
  end
end

