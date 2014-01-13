require 'set'

module Viewr
  class SchemaObjectRunner < ::Set

    attr_reader :adapter
    attr_accessor :already_run

    def initialize(adapter, views_and_functions = [])
      super(views_and_functions)
      @adapter = adapter
      @already_run = Set.new
    end

    def find_by_names(names)
      self.select { |view_or_function| names.include? view_or_function.name }.to_set
    end

    def run(view_or_function, method)
      return if already_run.include?(view_or_function)

      dependencies = find_by_names(view_or_function.dependencies)

      if !view_or_function.has_dependencies? || dependencies.subset?(already_run)
        adapter.send(method, view_or_function)
        already_run << view_or_function
      else
        (dependencies - already_run).each do |dependency|
          run(dependency, method)
        end
        run(view_or_function, method)
      end
    end

    def run_all(method)
      self.each { |view_or_function| run(view_or_function, method) }
    end

  end
end

