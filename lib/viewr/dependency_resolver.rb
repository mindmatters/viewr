require "set"

module Viewr
  UnsatisfiableDependenciesError = Class.new(StandardError)

  module DependencyResolver
    extend self

    def resolve_to_sequence(items)
      resolve(Set.new(items), [])
    end

    private

    def resolve(unresolved, resolved)
      if unresolved.empty?
        resolved
      else
        resolvables = unresolved.select { |item| all_dependencies_met?(item, resolved) }

        if resolvables.empty?
          raise UnsatisfiableDependenciesError
        else
          resolve(unresolved - resolvables, resolved + resolvables)
        end
      end
    end

    def all_dependencies_met?(item, resolved)
      item.dependencies.empty? || item.dependencies.to_set.subset?(resolved.map(&:name).to_set)
    end

  end
end
