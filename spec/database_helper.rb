require "yaml"
require "sequel"

module SpecSupport
  module DatabaseHelpers

    def test_database
      @database ||= begin
        config_path = File.expand_path('../support/database.yml', __FILE__)
        config = File.read(config_path)
        Sequel.connect(YAML.load(config))
      end
    end

  end
end

RSpec::Matchers.define :exist_as_view do
  match do |object_name|
    test_database.fetch(<<-SQL).count == 1
      SELECT 1
      FROM pg_catalog.pg_class c
      JOIN pg_namespace n
        ON (n.oid = c.relnamespace)
      WHERE n.nspname = ANY(CURRENT_SCHEMAS(false))
        AND c.relkind IN ('v', 'm')
        AND c.relname = '#{object_name}'
    SQL
  end
end

RSpec::Matchers.define :exist_as_function do
  match do |object_name|
    test_database.fetch(<<-SQL).count == 1
      SELECT 1
      FROM pg_catalog.pg_proc p
      JOIN pg_namespace n
        ON (n.oid = p.pronamespace)
      WHERE n.nspname = ANY(CURRENT_SCHEMAS(false))
        AND p.proname = '#{object_name}'
    SQL
  end
end

RSpec.configure do |config|
  config.include SpecSupport::DatabaseHelpers
  config.backtrace_exclusion_patterns = [/rspec-core/]

  config.around(:each) do |example|
    test_database.transaction do
      example.run
      raise Sequel::Error::Rollback
    end
  end
end
