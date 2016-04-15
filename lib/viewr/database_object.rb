require 'yaml'

module Viewr
  class DatabaseObject
    attr_reader :name, :dependencies, :sql, :adapter

    def initialize(function_doc, adapter)
      @name = function_doc['name']
      @dependencies = function_doc['dependencies']
      @sql = function_doc['sql']
      @adapter = adapter
    end

    def self.new_from_yaml(yaml, adapter)
      new(YAML.load(yaml), adapter)
    end

    def dependencies
      @dependencies || []
    end

    def create
      raise '#create is not implemented'
    end

    def drop
      raise '#drop is not implemented'
    end

    def eql?(another_function)
      self.name == another_function.name
    end

    def hash
      self.name.hash
    end
  end
end

