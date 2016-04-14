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
      expect(database_object.name).to eql('foo')
      expect(database_object.dependencies).to eql(['bar', 'baz'])
      expect(database_object.sql).to eql('SOME SQL STATEMENT FOR FOO HERE')
      expect(database_object.adapter).to eql(:adapter)
    end
  end

  describe '.new_from_yaml' do
    it 'creates a view with the parsed yaml' do
      database_object = Viewr::DatabaseObject.new_from_yaml(yaml, :adapter)

      expect(database_object.name).to eql('foo')
      expect(database_object.dependencies).to eql(['bar'])
      expect(database_object.sql).to eql('SQL')
      expect(database_object.adapter).to eql(:adapter)
    end
  end

  describe '#dependencies' do
    it 'returns an empty array if the view has no dependencies' do
      expect(Viewr::DatabaseObject.new(view_doc_without_dependencies, :adapter).dependencies).to eql([])
    end

    it 'returns the dependencies' do
      expect(Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter).dependencies).to eql(['bar', 'baz'])
    end
  end

  describe '#has_dependencies?' do
    it 'returns true if the view has dependencies' do
      expect(Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter)).to have_dependencies
    end

    it 'returns false if the view doesn‘t have dependencies' do
      expect(Viewr::DatabaseObject.new(view_doc_without_dependencies, :adapter)).not_to have_dependencies
    end
  end

  # This allows us to use this class as entries for a Set
  describe '#eql' do
    it 'is true if the views contain the same data' do
      view1 = Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter)
      view2 = Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter)

      expect(view1).to eql(view2)
    end
  end

  describe '#hash' do
    it 'returns the same hash as another view with the same name' do
      view1 = Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter)
      view2 = Viewr::DatabaseObject.new(view_doc_with_dependencies, :adapter)

      expect(view1.hash).to eql(view2.hash)
    end
  end
end

