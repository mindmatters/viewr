require "database_helper"
require_relative '../../lib/viewr/database_adapter'

describe Viewr::DatabaseAdapter, type: :database do

  let(:connection) { test_database }
  let(:database_adapter) { Viewr::DatabaseAdapter.new(connection) }

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
  end

end
