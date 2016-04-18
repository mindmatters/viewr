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
      if view_exists?(view_name)
        run(drop_view_sql(view_name))
      end
    end

    def drop_function(function_name)
      fully_qualified_function_names(function_name).each do |fully_qualified_function_name|
        run(drop_function_sql(fully_qualified_function_name))
      end
    end

    private

    def drop_view_sql(view_name)
      case view_type(view_name)
      when :view then "DROP VIEW #{view_name}"
      when :materialized_view then "DROP MATERIALIZED VIEW #{view_name}"
      end
    end

    def drop_function_sql(fully_qualified_function_name)
      "DROP FUNCTION #{fully_qualified_function_name}"
    end

    def view_exists?(view_name)
      !view_type(view_name).nil?
    end

    def view_type(view_name)
      result = @connection.fetch(%Q(
        SELECT relkind
        FROM pg_catalog.pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relname = '#{view_name}'
      )).first

      case
      when result.nil? then nil
      when result[:relkind] == 'v' then :view
      when result[:relkind] == 'm' then :materialized_view
      end
    end

    def fully_qualified_function_names(function_name)
      @connection.fetch(<<-SQL).map { |row| row[:name] }
        SELECT
          format('%s.%s (%s)',
            nspname,
            proname,
            oidvectortypes(proargtypes)
          ) AS name
        FROM pg_proc
        INNER JOIN pg_namespace ON (pg_namespace.oid = pg_proc.pronamespace)
        WHERE proname = '#{function_name}'
      SQL
    end
  end
end
