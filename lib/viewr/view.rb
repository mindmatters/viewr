require_relative 'database_object'

module Viewr
  class View < DatabaseObject

    def initialize(specification, adapter)
      @type = specification.fetch('type', :view)
      super
    end

    def create
      @adapter.create_view(self)
    end

    def drop
      @adapter.drop_view(self)
    end
  end
end
