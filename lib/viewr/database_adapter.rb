module Viewr

  AmbiguousNameInCurrentSearchPath = Class.new(StandardError)

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
      when :view then "DROP VIEW #{view_name} CASCADE"
      when :materialized_view then "DROP MATERIALIZED VIEW #{view_name} CASCADE"
      end
    end

    def drop_function_sql(fully_qualified_function_name)
      "DROP FUNCTION #{fully_qualified_function_name} CASCADE"
    end

    def view_exists?(view_name)
      !view_type(view_name).nil?
    end

    def view_type(view_name)
      result = @connection.fetch(%Q(
        SELECT relkind
        FROM pg_catalog.pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = ANY(CURRENT_SCHEMAS(false))
          AND c.relname = '#{view_name}'
      ))

      if result.count > 1
        raise_ambiguity_error(view_name)
      end

      case
      when result.count != 1 then nil
      when result.first[:relkind] == 'v' then :view
      when result.first[:relkind] == 'm' then :materialized_view
      end
    end

    def fully_qualified_function_names(function_name)
      result = @connection.fetch <<-SQL
        SELECT
          format('%s.%s (%s)',
            n.nspname,
            p.proname,
            oidvectortypes(p.proargtypes)
          ) AS name,
          n.nspname AS namespace
        FROM pg_proc p
        JOIN pg_namespace n ON (n.oid = p.pronamespace)
        WHERE n.nspname = ANY(CURRENT_SCHEMAS(false))
          AND p.proname = '#{function_name}'
      SQL

      if result.map { |row| row[:namespace] }.uniq.count > 1
        raise_ambiguity_error(function_name)
      end

      result.map { |row| row[:name] }
    end

    def raise_ambiguity_error(object_name)
      msg = "The database object #{object_name} exists multiple times within the current search path."
      raise AmbiguousNameInCurrentSearchPath.new(msg)
    end
  end
end
