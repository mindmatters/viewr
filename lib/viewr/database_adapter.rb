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
      return unless view_exists?(view_name)

      run(drop_view_sql(view_name))
    end

    def drop_function(function_name)
      existing_functions_with_argument_types(function_name).each do |function_with_argument_types|
        run(drop_function_sql(function_with_argument_types))
      end
    end

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

    private

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

