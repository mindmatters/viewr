require 'set'
require_relative 'exception'

module Viewr
  class SchemaObjectRunner < ::Set

    attr_accessor :already_run

    def initialize(views_and_functions = [])
      super(views_and_functions)
      @already_run = Set.new
    end

    def find_by_names(names)
      self.select { |database_object| names.include? database_object.name }.to_set
    end

    def run(database_object, method)
      return if already_run.include?(database_object)

      dependencies = find_by_names(database_object.dependencies)

      if !database_object.has_dependencies? or dependencies.subset?(already_run)
        begin
          database_object.send(method)
        rescue StandardError => e
          raise Viewr::SQLError.new "Error while processing #{database_object.name}: #{e.message}"
        end

        already_run << database_object
      else
        (dependencies - already_run).each do |dependency|
          run(dependency, method)
        end

        run(database_object, method)
      end
    end

    def create_all
      self.each { |database_object| run(database_object, :create) }
    end

    def drop_all
      self.each { |database_object| run(database_object, :drop) }
    end
  end
end

