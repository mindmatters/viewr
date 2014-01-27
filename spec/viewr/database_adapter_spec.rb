require_relative '../../lib/viewr/database_adapter'

describe Viewr::DatabaseAdapter do

  let(:connection) { double(:connection) }
  let(:database_adapter) { Viewr::DatabaseAdapter.new(connection) }

  describe '#initialize' do
    it 'saves the given connection to an attribute' do
      database_adapter.connection.should == connection
    end
  end

  describe '#run' do
    it 'runs the given statement on its inner connection' do
      connection.should_receive(:run).with(:sql_statement)

      database_adapter.run(:sql_statement)
    end
  end

  describe '#drop_view' do
    it 'runs the SQL statement returned by #drop_view_sql' do
      database_adapter.should_receive(:drop_view_sql).with(:view).and_return(:sql_statement)
      database_adapter.should_receive(:run).with(:sql_statement)

      database_adapter.drop_view(:view)
    end
  end

  describe '#drop_function' do
    it 'runs the SQL statement returned by #drop_function_sql' do
      database_adapter.should_receive(:drop_function_sql).with(:function).and_return(:sql_statement)
      database_adapter.should_receive(:run).with(:sql_statement)

      database_adapter.drop_function(:function)
    end

  end

  describe '#drop_view_sql' do
    it 'returns an SQL statement to drop the given view' do
      view = double(:view, name: 'view_name')

      database_adapter.drop_view_sql(view).should == 'DROP VIEW IF EXISTS view_name CASCADE'
    end
  end

  describe '#drop_function_sql' do
    it 'returns an SQL statement to drop the given function' do
      function = double(:function, name: 'function_name')

      database_adapter.drop_function_sql(function).should == 'DROP FUNCTION IF EXISTS function_name CASCADE'
    end
  end
end
