module Viewr
  class DatabaseAdapter
    attr_accessor :connection

    def initialize(connection)
      @connection = connection
    end

    def run(statement)
      connection.run(statement)
    end

    def drop_view(view_name)
      run(drop_view_sql(view_name))
    end

    def drop_function(function_name)
      run(drop_function_sql(function_name))
    end

    def drop_view_sql(view_name)
      "DROP VIEW IF EXISTS #{view_name} CASCADE"
    end

    def drop_function_sql(function_name)
      "DROP FUNCTION IF EXISTS #{function_name} CASCADE"
    end
  end
end

