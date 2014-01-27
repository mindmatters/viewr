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
      existing_functions_with_argument_types(function_name).each do |function_with_argument_types|
        run(drop_function_sql(function_with_argument_types))
      end
    end

    def drop_view_sql(view_name)
      "DROP VIEW IF EXISTS #{view_name} CASCADE"
    end

    def drop_function_sql(function_with_argument_types)
      "DROP FUNCTION IF EXISTS #{function_with_argument_types} CASCADE"
    end

    def existing_functions_with_argument_types(function_name)
      functions = []
      @connection["
        SELECT
          nspname,
          proname,
          oidvectortypes(proargtypes) AS args
        FROM pg_proc
        INNER JOIN pg_namespace ON (pg_namespace.oid = pg_proc.pronamespace)
        WHERE (proname = '#{function_name}')"].each do |r|
          functions << "#{r[:nspname]}.#{r[:proname]} (#{r[:args]})"
        end
      functions
    end
  end
end

