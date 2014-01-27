require_relative 'database_object'

module Viewr
  class View < DatabaseObject
    def create
      @adapter.run(@sql)
    end

    def drop
      @adapter.drop_view(@name)
    end
  end
end

