module Viewr
  module DatabaseAdapter
    class Postgres
      attr_accessor :connection

      def initialize(connection)
        @connection = connection
      end

      def run(statement)
        connection.run(statement)
      end

      def drop_view_sql(view)
        "DROP VIEW IF EXISTS #{view.name} CASCADE;"
      end

      def create_view_sql(view)
        "CREATE VIEW #{view.name} AS (#{view.sql});"
      end

      def drop_view(view)
        run(drop_view_sql(view))
      end

      def create_view(view)
        run(create_view_sql(view))
      end

      def recreate_view(view)
        drop_view(view)
        create_view(view)
      end

      def drop_function_sql(function)
        "DROP FUNCTION IF EXISTS #{function.name} CASCADE"
      end

      def create_function_sql(function)
        "CREATE FUNCTION #{function.name}(#{function.arguments.join(', ')}) RETURNS #{function.returns} AS $BODY$ #{function.sql}; $BODY$ LANGUAGE SQL"
      end

      def drop_function(function)
        run(drop_function_sql(function))
      end

      def create_function(function)
        run(create_function_sql(function))
      end

      def recreate_function(function)
        drop_function(function)
        create_function(function)
      end
    end
  end
end

