require_relative '../lib/viewr/schema_object_runner'
require_relative '../lib/viewr/view'

describe Viewr::SchemaObjectRunner do

  let (:adapter) { double.as_null_object }

  describe '.new' do
    it 'creates inner references to its given adapter and viewlist' do
      viewlist = [double]

      schema_object_runner = Viewr::SchemaObjectRunner.new(adapter, viewlist)

      schema_object_runner.adapter.should == adapter
      schema_object_runner.should be_a(Set)
      schema_object_runner.first.should == viewlist.first
    end

    it 'initializes as empty Set if no starting Set is given' do
      schema_object_runner = Viewr::SchemaObjectRunner.new(adapter)
      schema_object_runner.should be_empty
    end
  end

  context 'given the following view list structure' do

    let (:view_with_dependency_foo1) do
      Viewr::View.new({
        'name' => 'foo1',
        'dependencies' => ['bar'],
        'sql' => 'SOME SQL STATEMENT FOR FOO1 HERE'
      })
    end

    let (:view_with_dependencies_foo2) do
      Viewr::View.new({
        'name' => 'foo2',
        'dependencies' => ['bar', 'baz'],
        'sql' => 'SOME SQL STATEMENT FOR FOO2 HERE'
      })
    end

    let (:view_without_dependency_bar) do
      Viewr::View.new({
        'name' => 'bar',
        'sql' => 'SOME SQL STATEMENT FOR BAR HERE'
      })
    end

    let (:view_without_dependency_baz) do
      Viewr::View.new({
        'name' => 'baz',
        'sql' => 'SOME SQL STATEMENT FOR BAZ HERE'
      })
    end

    let (:viewlist) do
      [
        view_with_dependency_foo1,
        view_with_dependencies_foo2,
        view_without_dependency_bar,
        view_without_dependency_baz
      ]
    end

    let (:schema_object_runner) { Viewr::SchemaObjectRunner.new(adapter, viewlist) }

    describe '#find_views' do
      it 'finds views by their names' do
        schema_object_runner.find_views(['foo1', 'foo2']).should == Set.new(
          [view_with_dependency_foo1, view_with_dependencies_foo2]
        )
      end
    end

    describe '#run' do

      it 'does not run the requested method on the view if it has already run' do
        view = view_without_dependency_bar
        schema_object_runner.already_run_views = Set.new [view]

        adapter.should_not_receive(:foo).with(view)

        schema_object_runner.run(view, :foo)
      end

      context 'called with a view that has no dependencies' do
        let (:view) { view_without_dependency_bar }

        it 'sends the requested method to the view' do
          adapter.should_receive(:foo).with(view)
          schema_object_runner.run(view, :foo)
        end

        it 'adds the run view to the inner list of already run views' do
          schema_object_runner.already_run_views.should == Set.new
          schema_object_runner.run(view, :foo)
          schema_object_runner.already_run_views.should == Set.new([view])
        end
      end

      context 'called with a view that has dependencies' do

        let (:view) { view_with_dependency_foo1 }

        context 'and all dependencies have already run' do

          before { schema_object_runner.already_run_views = Set.new([view_without_dependency_bar]) }

          it 'sends the requested method to the view' do
            adapter.should_receive(:foo).with(view)
            schema_object_runner.run(view, :foo)
          end

          it 'adds the run view to the inner list of already run views' do
            schema_object_runner.run(view, :foo)
            schema_object_runner.already_run_views.should == Set.new(
              [view_without_dependency_bar, view]
            )
          end

        end

        context 'and some or all dependencies have not already run' do

          let (:view) { view_with_dependencies_foo2 }
          before { schema_object_runner.already_run_views = Set.new([view_without_dependency_bar]) }

          it 'first sends the method to the not-already-run dependent views ' +
             'and then to the view itself' do
            adapter.should_receive(:foo).with(view_without_dependency_baz).ordered
            adapter.should_receive(:foo).with(view).ordered

            schema_object_runner.run(view, :foo)
          end

          it 'does not send the method to the dependent views that have already run' do
            adapter.should_not_receive(:foo).with(view_without_dependency_bar)
            schema_object_runner.run(view, :foo)
          end

          it 'adds the now run views to the inner list of already run views' do
            schema_object_runner.run(view, :foo)

            schema_object_runner.already_run_views.should eql(
              Set.new([
                view_without_dependency_bar,
                view_without_dependency_baz,
                view
              ])
            )
          end

        end

      end

    end

    describe '#run_all' do
      it 'runs #run for every view' do
        viewlist = [view_with_dependency_foo1, view_with_dependencies_foo2]
        schema_object_runner = Viewr::SchemaObjectRunner.new(adapter, viewlist)

        schema_object_runner.should_receive(:run).with(view_with_dependency_foo1, :foo)
        schema_object_runner.should_receive(:run).with(view_with_dependencies_foo2, :foo)

        schema_object_runner.run_all(:foo)
      end
    end

  end

end

