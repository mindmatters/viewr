require 'yaml'

module Viewr
  class DatabaseObject
    attr_reader :name, :dependencies, :sql, :adapter

    def initialize(specification, adapter)
      @name = specification.fetch('name')
      @sql = specification.fetch('sql')

      @dependencies = specification['dependencies']

      @adapter = adapter
    end

    def self.new_from_yaml(yaml, adapter)
      new(YAML.load(yaml), adapter)
    end

    def has_dependencies?
      !dependencies.empty?
    end

    def dependencies
      @dependencies || []
    end

    def create
      fail '#create is not implemented'
    end

    def drop
      fail '#drop is not implemented'
    end

    def eql?(another_function)
      self.name == another_function.name
    end

    def hash
      self.name.hash
    end
  end
end
