require_relative '../../lib/viewr/schema_object_runner'
require_relative '../../lib/viewr/exception'

describe Viewr::SchemaObjectRunner do

  let(:foo) { double(:view_or_function, name: 'foo', dependencies: [], has_dependencies?: false) }
  let(:bar) { double(:view_or_function, name: 'bar', dependencies: ['foo'], has_dependencies?: true) }
  let(:qux) { double(:view_or_function, name: 'qux', dependencies: [], has_dependencies?: true) }

  let (:schema_object_runner) { Viewr::SchemaObjectRunner.new([foo, bar, qux]) }

  describe '.new' do
    it 'saves references to the given array of views and functions' do
      expect(schema_object_runner).to be_a(Set)
      schema_object_runner == Set.new([foo, bar, qux])
    end

    it 'initializes as empty Set if no starting Set is given' do
      schema_object_runner = Viewr::SchemaObjectRunner.new
      expect(schema_object_runner).to be_empty
    end
  end

  describe '#find_by_names' do
    it 'finds views by their names' do
      expect(schema_object_runner.find_by_names(['foo', 'bar'])).to eql Set.new([foo, bar])
    end
  end

  describe '#run' do
    it 'does not run the requested method on the view if it has already run' do
      expect(schema_object_runner).to receive(:find_by_names).with([]).and_return(Set.new)
      expect(foo).to receive(:send).with(:method).once

      schema_object_runner.run(foo, :method)
      schema_object_runner.run(foo, :method)
    end

    it 'raises a Viewr::SQLError exception when a postgres error occurs' do
      expect(schema_object_runner).to receive(:find_by_names).with([]).and_return(Set.new)
      expect(foo).to receive(:send).with(:method).and_raise(StandardError.new('MESSAGE'))

      expect { schema_object_runner.run(foo, :method) }.to raise_error(Viewr::SQLError)
    end

    context 'called with a view that has dependencies' do
      context 'and all dependencies have already run' do
        before do
          expect(schema_object_runner).to receive(:find_by_names).and_return(Set.new)
          expect(foo).to receive :send

          schema_object_runner.run(foo, :method)
        end

        it 'sends the requested method to the view' do
          expect(schema_object_runner).to receive(:find_by_names).with(['foo']).and_return(Set.new([foo]))
          expect(bar).to receive(:send).with(:method)

          schema_object_runner.run(bar, :method)
        end
      end

      context 'and dependencies have not yet been run' do
        it 'first runs the view depended upon and then the given view' do
          expect(schema_object_runner).to receive(:find_by_names).twice.with(['foo']).and_return(Set.new([foo]))
          expect(schema_object_runner).to receive(:find_by_names).with([]).and_return(Set.new)
          expect(foo).to receive(:send).with(:method).ordered
          expect(bar).to receive(:send).with(:method).ordered

          schema_object_runner.run(bar, :method)
        end
      end

      context 'and dependencies have already been run' do
        before do
          expect(schema_object_runner).to receive(:find_by_names).with([]).and_return(Set.new)
          expect(foo).to receive(:send).with(:method).ordered
          schema_object_runner.run(foo, :method)
        end

        it 'does not send the method to the dependent views that have already run' do
          expect(schema_object_runner).to receive(:find_by_names).with(['foo']).and_return(Set.new([foo]))
          expect(foo).not_to receive(:send).with(:method)
          expect(bar).to receive(:send).with(:method)

          schema_object_runner.run(bar, :method)
        end
      end
    end
  end

  describe '#create_all' do
    it 'runs all database objects with method :create' do
      expect(schema_object_runner).to receive(:run).with(foo, :create)
      expect(schema_object_runner).to receive(:run).with(bar, :create)
      expect(schema_object_runner).to receive(:run).with(qux, :create)

      schema_object_runner.create_all
    end
  end

  describe '#drop_all' do
    it 'runs all database objects with method :drop' do
      expect(schema_object_runner).to receive(:run).with(foo, :drop)
      expect(schema_object_runner).to receive(:run).with(bar, :drop)
      expect(schema_object_runner).to receive(:run).with(qux, :drop)

      schema_object_runner.drop_all
    end

  end
end

