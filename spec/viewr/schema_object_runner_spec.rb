require_relative '../../lib/viewr/schema_object_runner'

describe Viewr::SchemaObjectRunner do

  let(:foo) { double(:view_or_function, name: 'foo', dependencies: []) }
  let(:bar) { double(:view_or_function, name: 'bar', dependencies: ['foo']) }

  let (:schema_object_runner) { Viewr::SchemaObjectRunner.new([bar, foo]) }

  describe '#create_all' do
    it 'runs all database objects in order with method :create' do
      expect(schema_object_runner).to receive(:run).with(foo, :create).ordered
      expect(schema_object_runner).to receive(:run).with(bar, :create).ordered

      schema_object_runner.create_all
    end
  end

  describe '#drop_all' do
    it 'runs all database objects with method :drop' do
      expect(schema_object_runner).to receive(:run).with(foo, :drop).ordered
      expect(schema_object_runner).to receive(:run).with(bar, :drop).ordered

      schema_object_runner.drop_all
    end
  end

  it 'raises a Viewr::SQLError exception when a postgres error occurs' do
    expect(foo).to receive(:method).and_raise(StandardError.new('MESSAGE'))

    expect { schema_object_runner.run(foo, :method) }.to raise_error(Viewr::SQLError)
  end
end

