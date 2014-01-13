require_relative '../lib/viewr'

describe Viewr::View do

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

  let (:yaml) { "---\nname: foo\nsql: 'SQL'" }

  describe '.new' do
    it 'creates accessors for the view typical properties' do
      view = Viewr::View.new(view_doc_with_dependencies)
      view.name.should == 'foo'
      view.dependencies.should == ['bar', 'baz']
      view.sql.should == 'SOME SQL STATEMENT FOR FOO HERE'
    end
  end

  describe '.new_from_yaml' do
    it 'creates a view with the parsed yaml' do
      view = Viewr::View.new_from_yaml(yaml)

      view.name.should == 'foo'
      view.sql.should == 'SQL'
    end
  end

  describe '.new_from_yaml_file' do
    it 'creates a view from the contents of a YAML file' do
      yaml_file_path = '/path/to/yaml/file'
      IO.should_receive(:read).with(yaml_file_path).and_return(yaml)

      view = Viewr::View.new_from_yaml_file(yaml_file_path)

      view.name.should == 'foo'
    end
  end

  describe '#dependencies' do
    it 'returns an empty Array if the view has no dependencies' do
      Viewr::View.new(view_doc_without_dependencies).dependencies.should == []
    end

    it 'returns the dependencies' do
      Viewr::View.new(view_doc_with_dependencies).dependencies.should == ['bar', 'baz']
    end
  end

  describe '#has_dependencies?' do
    it 'returns true if the view has dependencies' do
      Viewr::View.new(view_doc_with_dependencies).has_dependencies?.should be_true
    end

    it 'returns false if the view doesn‘t have dependencies' do
      Viewr::View.new(view_doc_without_dependencies).has_dependencies?.should be_false
    end
  end

  # This allows us to use this class as entries for a Set
  describe '#eql' do
    it 'is true if the views contain the same data' do
      view1 = Viewr::View.new(view_doc_with_dependencies)
      view2 = Viewr::View.new(view_doc_with_dependencies)

      view1.should eql(view2)
    end
  end

  describe '#hash' do
    it 'returns the same hash as another view with the same name' do
      view1 = Viewr::View.new(view_doc_with_dependencies)
      view2 = Viewr::View.new(view_doc_with_dependencies)

      view1.hash.should == view2.hash
    end
  end
end
