require 'set'

module Viewr
  class SchemaObjectRunner < ::Set

    attr_reader :adapter
    attr_accessor :already_run_views

    def initialize(adapter, viewlist = [])
      super(viewlist)
      @adapter = adapter
      @already_run_views = Set.new
    end

    def find_views(names)
      self.select { |view| names.include? view.name }.to_set
    end

    def run(view, method)
      return if already_run_views.include?(view)

      dependent_views = find_views(view.dependency_view_names)

      if !view.has_dependencies? || dependent_views.subset?(already_run_views)
        adapter.send(method, view)
        already_run_views << view
      else
        (dependent_views - already_run_views).each do |dependent_view|
          run(dependent_view, method)
        end
        run(view, method)
      end
    end

    def run_all(method)
      self.each { |view| run(view, method) }
    end

  end
end

