require_relative 'dependency_resolver'

module Viewr
  SQLError = Class.new(StandardError)

  class SchemaObjectRunner

    def initialize(database_objects = [])
      @items = DependencyResolver.resolve_to_sequence(database_objects)
    end

    def create_all
      @items.each { |database_object| run(database_object, :create) }
    end

    def drop_all
      @items.each { |database_object| run(database_object, :drop) }
    end

    def run(database_object, method)
      begin
        database_object.public_send(method)
      rescue StandardError => e
        raise SQLError.new "Error while processing #{database_object.name}: #{e.message}"
      end
    end

  end
end

