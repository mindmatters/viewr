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
    end
  end
end

