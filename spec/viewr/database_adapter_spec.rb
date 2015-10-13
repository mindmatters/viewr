require_relative '../../lib/viewr/database_adapter'

describe Viewr::DatabaseAdapter do

  let(:connection) { double(:connection) }
  let(:database_adapter) { Viewr::DatabaseAdapter.new(connection) }

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
      allow(database_adapter).to receive(:view_exists?).with(:view_name).and_return(false)
      expect(database_adapter).not_to receive(:run)

      database_adapter.drop_view(:view_name)
    end

    it 'runs the SQL statement returned by #drop_view_sql' do
      allow(database_adapter).to receive(:view_exists?).with(:view_name).and_return(true)
      expect(database_adapter).to receive(:drop_view_sql).with(:view_name).and_return(:sql_statement)
      expect(database_adapter).to receive(:run).with(:sql_statement)

      database_adapter.drop_view(:view_name)
    end
  end

  describe '#drop_function' do
    it 'runs the SQL statement returned by #drop_function_sql' do
      expect(database_adapter).to receive(:existing_functions_with_argument_types).with(:function_name).and_return([:foo])
      expect(database_adapter).to receive(:drop_function_sql).with(:foo).and_return(:sql_statement)
      expect(database_adapter).to receive(:run).with(:sql_statement)

      database_adapter.drop_function(:function_name)
    end

  end

  describe '#drop_view_sql' do
    it 'returns an SQL statement to drop the given view if type is :view' do
      allow(database_adapter).to receive(:view_type).with('view_name').and_return(:view)

      expect(database_adapter.drop_view_sql('view_name')).to eql('DROP VIEW IF EXISTS view_name CASCADE')
    end

    it 'returns an SQL statement to drop the given materialized view if type is :materialized_view' do
      allow(database_adapter).to receive(:view_type).with('view_name').and_return(:materialized_view)

      expect(database_adapter.drop_view_sql('view_name')).to eql('DROP MATERIALIZED VIEW view_name CASCADE')
    end
  end

  describe '#drop_function_sql' do
    it 'returns an SQL statement to drop the given function' do
      expect(database_adapter.drop_function_sql('function_name')).to eql('DROP FUNCTION IF EXISTS function_name CASCADE')
    end
  end

  describe '#view_exists?' do
    it 'returns false if view type is nil' do
      allow(database_adapter).to receive(:view_type).with(:view_name).and_return(nil)

      result = database_adapter.view_exists?(:view_name)

      expect(result).to be false
    end

    it 'returns true if view type is not nil' do
      allow(database_adapter).to receive(:view_type).with(:view_name).and_return(:view)

      result = database_adapter.view_exists?(:view_name)

      expect(result).to be true
    end
  end
end
