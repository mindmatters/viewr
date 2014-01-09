require_relative '../../lib/viewr/database_adapter/postgres'

describe Viewr::DatabaseAdapter::Postgres do

  let (:connection) { double }
  let (:postgres_adapter) { Viewr::DatabaseAdapter::Postgres.new(connection) }
  let (:view_foo) { double(name: 'foo', sql: 'foo_sql') }

  describe '.new' do
    it 'creates an inner reference to its given connection' do
      postgres_adapter.connection.should == connection
    end
  end

  describe '#run' do
    it 'runs the given statement on its inner connection' do
      statement = 'SOME SQL'
      connection.should_receive(:run).with(statement)
      postgres_adapter.run(statement)
    end
  end

  describe '#drop_view_sql' do
    it 'returns the SQL for dropping a view' do
      postgres_adapter.drop_view_sql(view_foo).should ==
        'DROP VIEW IF EXISTS foo CASCADE;'
    end
  end

  describe '#create_view_sql' do
    it 'return the SQL for creating a view' do
      postgres_adapter.create_view_sql(view_foo).should ==
        'CREATE VIEW foo AS (foo_sql);'
    end
  end

  describe '#drop_view' do
    it 'actually drops the given view via the connection' do
      drop_sql = double
      postgres_adapter.should_receive(:drop_view_sql).and_return(drop_sql)
      postgres_adapter.should_receive(:run).with(drop_sql)

      postgres_adapter.drop_view(view_foo)
    end
  end

  describe '#create_view' do
    it 'actually creates the given view via the connection' do
      create_sql = double
      postgres_adapter.should_receive(:create_view_sql).and_return(create_sql)
      postgres_adapter.should_receive(:run).with(create_sql)

      postgres_adapter.create_view(view_foo)
    end
  end

  describe '#recreate_view' do
    it 'first drops, then creates the given view via the connection' do
      postgres_adapter.should_receive(:drop_view).with(view_foo).ordered
      postgres_adapter.should_receive(:create_view).with(view_foo).ordered

      postgres_adapter.recreate_view(view_foo)
    end
  end

end

