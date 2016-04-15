require_relative '../../lib/viewr/database_adapter'

describe Viewr::DatabaseAdapter do

  let(:connection) { double(:connection) }
  let(:database_adapter) { Viewr::DatabaseAdapter.new(connection) }
  let(:function) {
    function_params = {
      'name' => 'function',
      'sql' => 'Select * FROM something;'
    }
    Viewr::Function.new(function_params, database_adapter) }
  let(:view) {
    view_params = {
      'name' => 'view',
      'sql' => 'Select * FROM something;'
    }
    Viewr::View.new(view_params, database_adapter) }
  let(:materialized_view) {
    materialized_view_params = {
      'name' => 'some_materialized_view',
      'type' => 'materialized_view',
      'sql' => 'Select * FROM something;'
    }
    Viewr::View.new(materialized_view_params, database_adapter)
  }

  describe '#initialize' do
    it 'saves the given connection to an attribute' do
      expect(database_adapter.connection).to eql(connection)
    end
  end

  describe '#run' do
    it 'runs the given statement on its inner connection' do
      expect(connection).to receive(:run).with(:sql_statement)

      database_adapter.run(:sql_statement)
    end
  end

  describe '#drop_view' do
    it 'does not run SQL statement if view does not exist' do
      expect(database_adapter).to receive(:view_exists?).with(view.name).and_return(false)
      expect(database_adapter).not_to receive(:run)

      database_adapter.drop_view(view)
    end

    it 'runs the SQL statement returned by #drop_view_sql' do
      expect(database_adapter).to receive(:view_exists?).with(view.name).and_return(true)
      expect(database_adapter).to receive(:drop_view_sql).with(view).and_return(:sql_statement)
      expect(database_adapter).to receive(:run).with(:sql_statement)

      database_adapter.drop_view(view)
    end
  end

  describe '#drop_function' do
    it 'runs the SQL statement returned by #drop_function_sql' do
      expect(database_adapter).to receive(:existing_functions_with_argument_types).with(function.name).and_return([:foo])
      expect(database_adapter).to receive(:drop_function_sql).with(:foo).and_return(:sql_statement)
      expect(database_adapter).to receive(:run).with(:sql_statement)

      database_adapter.drop_function(function)
    end

  end

  describe '#drop_view_sql' do
    it 'returns an SQL statement to drop the given view if type is :view' do
      expect(database_adapter.drop_view_sql(view)).to eql("DROP VIEW IF EXISTS #{view.name} CASCADE")
    end

    it 'returns an SQL statement to drop the given materialized view if type is :materialized_view' do
      expect(database_adapter.drop_view_sql(materialized_view)).to eql("DROP MATERIALIZED VIEW #{materialized_view.name} CASCADE")
    end
  end

  describe '#drop_function_sql' do
    it 'returns an SQL statement to drop the given function' do
      expect(database_adapter.drop_function_sql('function_name')).to eql('DROP FUNCTION IF EXISTS function_name CASCADE')
    end
  end

  describe '#view_exists?' do
    it 'returns false if view type is nil' do
      expect(database_adapter).to receive(:view_exists_in_database?).with(view).and_return(nil)

      result = database_adapter.view_exists?(view)

      expect(result).to be false
    end

    it 'returns true if view type is not nil' do
      expect(database_adapter).to receive(:view_exists_in_database?).with(view).and_return(:view)

      result = database_adapter.view_exists?(view)

      expect(result).to be true
    end
  end
end
