require_relative 'database_object'

module Viewr
  class Function < DatabaseObject
    def create
      @adapter.run(@sql)
    end

    def drop
      @adapter.drop_function(self)
    end
  end
end
