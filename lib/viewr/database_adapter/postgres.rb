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

      def drop_sql(view)
        "DROP VIEW IF EXISTS #{view.name} CASCADE;"
      end

      def create_sql(view)
        "CREATE VIEW #{view.name} AS (#{view.sql});"
      end

      def drop(view)
        run(drop_sql(view))
      end

      def create(view)
        run(create_sql(view))
      end

      def recreate(view)
        drop(view)
        create(view)
      end
    end
  end
end

