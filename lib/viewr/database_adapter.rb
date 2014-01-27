module Viewr
  class DatabaseAdapter
    attr_accessor :connection

    def initialize(connection)
      @connection = connection
    end

    def run(statement)
      connection.run(statement)
    end

    def drop_view(view)
      run(drop_view_sql(view))
    end

    def drop_function(function)
      run(drop_function_sql(function))
    end

    def drop_view_sql(view)
      "DROP VIEW IF EXISTS #{view.name} CASCADE"
    end

    def drop_function_sql(function)
      "DROP FUNCTION IF EXISTS #{function.name} CASCADE"
    end
  end
end

