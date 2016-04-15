require_relative 'database_object'

module Viewr
  class Function < DatabaseObject

    def initialize(specification, adapter)
      @type = :function
      super
    end

    def create
      @adapter.create_function(self)
    end

    def drop
      @adapter.drop_function(self)
    end
  end
end
