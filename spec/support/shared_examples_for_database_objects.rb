# coding: utf-8
require_relative '../../lib/viewr/database_object'

shared_examples 'a database object' do

  let (:yaml) { "---\nname: foo\ndependencies:\n  - 'bar'\nsql: 'SQL'" }
  let (:view_doc_with_dependencies) do
    {
      'name' => 'foo',
      'dependencies' => ['bar', 'baz'],
      'sql' => 'SOME SQL STATEMENT FOR FOO HERE'
    }
  end
  let (:view_doc_without_dependencies) do
    {
      'name' => 'bar',
      'sql' => 'SOME SQL STATEMENT FOR BAR HERE'
    }
  end

  describe '#initialize' do
    it 'creates accessors for the view typical properties' do
      database_object = Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter)
      database_object.name.should == 'foo'
      database_object.dependencies.should == ['bar', 'baz']
      database_object.sql.should == 'SOME SQL STATEMENT FOR FOO HERE'
      database_object.adapter.should == :adapter
    end
  end

  describe '.new_from_yaml' do
    it 'creates a view with the parsed yaml' do
      database_object = Viewr::DatabaseObject.new_from_yaml(yaml, :adapter)

      database_object.name.should == 'foo'
      database_object.dependencies.should == ['bar']
      database_object.sql.should == 'SQL'
      database_object.adapter.should == :adapter
    end
  end

  describe '#dependencies' do
    it 'returns an empty array if the view has no dependencies' do
      Viewr::DatabaseObject.new(view_doc_without_dependencies, :adapter).dependencies.should == []
    end

    it 'returns the dependencies' do
      Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter).dependencies.should == ['bar', 'baz']
    end
  end

  describe '#has_dependencies?' do
    it 'returns true if the view has dependencies' do
      Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter).has_dependencies?.should be_true
    end

    it 'returns false if the view doesn‘t have dependencies' do
      Viewr::DatabaseObject.new(view_doc_without_dependencies, :adapter).has_dependencies?.should be_false
    end
  end

  # This allows us to use this class as entries for a Set
  describe '#eql' do
    it 'is true if the views contain the same data' do
      view1 = Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter)
      view2 = Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter)

      view1.should eql(view2)
    end
  end

  describe '#hash' do
    it 'returns the same hash as another view with the same name' do
      view1 = Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter)
      view2 = Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter)

      view1.hash.should == view2.hash
    end
  end
end

