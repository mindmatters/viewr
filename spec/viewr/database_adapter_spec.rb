require "database_helper"
require_relative '../../lib/viewr/database_adapter'

describe Viewr::DatabaseAdapter, type: :database do

  let(:connection) { test_database }
  let(:database_adapter) { Viewr::DatabaseAdapter.new(connection) }

  around do |example|
    test_database.run <<-SQL
      CREATE SCHEMA other_schema;
    SQL

    example.run

    test_database.run <<-SQL
      SET search_path TO public;
      DROP SCHEMA other_schema CASCADE;
    SQL
  end

  describe '#run' do
    it 'runs the given statement on its inner connection' do
      expect(connection).to receive(:run).with(:sql_statement)

      database_adapter.run(:sql_statement)
    end
  end

  describe '#drop_view' do
    before do
      test_database.run <<-SQL
        CREATE VIEW example_view AS
          SELECT 'foo'::VARCHAR;

        CREATE MATERIALIZED VIEW example_materialized_view AS
          SELECT 'bar'::VARCHAR;
      SQL
    end

    it 'drops views by the given name' do
      expect("example_view").to exist_as_view

      database_adapter.drop_view("example_view")

      expect("example_view").not_to exist_as_view
    end

    it 'drops materialized views by the given name' do
      expect("example_materialized_view").to exist_as_view

      database_adapter.drop_view("example_materialized_view")

      expect("example_materialized_view").not_to exist_as_view
    end

    it 'does not raise if view does not exist' do
      expect {
        database_adapter.drop_view("foooo")
      }.not_to raise_error
    end

    context "schema support" do
      before do
        test_database.run <<-SQL
          CREATE VIEW other_schema.example_view AS
            SELECT 'other example'::VARCHAR;
        SQL
      end

      it "respects the current search path option" do
        test_database.run "SET search_path TO public"

        database_adapter.drop_view("example_view")
        expect("example_view").not_to exist_as_view

        test_database.run "SET search_path TO other_schema"
        expect("example_view").to exist_as_view
      end

      it "raises when view exists in multiple schemas in search path" do
        test_database.run "SET search_path TO public, other_schema"

        expect {
          database_adapter.drop_view("example_view")
        }.to raise_error Viewr::AmbiguousNameInCurrentSearchPath
      end
    end
  end

  describe '#drop_function' do
    before do
      test_database.run <<-SQL
        CREATE FUNCTION example_function(n INTEGER)
          RETURNS INTEGER
          AS
          $BODY$
          SELECT n
          $BODY$
          LANGUAGE sql;

        CREATE FUNCTION example_function(n INTEGER, s VARCHAR)
          RETURNS INTEGER
          AS
          $BODY$
          SELECT n
          $BODY$
          LANGUAGE sql;
      SQL
    end

    it "drops all functions by the given name" do
      expect("example_function").to exist_as_function

      database_adapter.drop_function("example_function")

      expect("example_function").not_to exist_as_function
    end

    context "schema support" do
      before do
        test_database.run <<-SQL
          CREATE FUNCTION other_schema.example_function(n INTEGER, s VARCHAR)
            RETURNS INTEGER
            AS
            $BODY$
            SELECT n
            $BODY$
            LANGUAGE sql;
        SQL
      end

      it "respects the current search path option" do
        test_database.run "SET search_path TO public"

        database_adapter.drop_function("example_function")
        expect("example_function").not_to exist_as_function

        test_database.run "SET search_path TO other_schema"
        expect("example_function").to exist_as_function
      end

      it "raises when function exists in multiple schemas in search path" do
        test_database.run "SET search_path TO public, other_schema"

        expect {
          database_adapter.drop_function("example_function")
        }.to raise_error Viewr::AmbiguousNameInCurrentSearchPath
      end
    end
  end

end
