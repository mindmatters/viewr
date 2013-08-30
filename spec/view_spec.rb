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
      view.dependency_view_names.should == ['bar', 'baz']
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

  describe '#dependency_view_names' do
    it 'returns an empty Array if the view has no dependencies' do
      Viewr::View.new(view_doc_without_dependencies).dependency_view_names.should == []
    end
  end

  describe '#has_dependencies?' do
    it 'reports if the current view has dependencies' do
      Viewr::View.new(view_doc_with_dependencies).has_dependencies?.should be_true
      Viewr::View.new(view_doc_without_dependencies).has_dependencies?.should be_false
    end
  end

  # This allows us to use this class as entries for a Set
  describe 'equality of two view' do
    it 'is given when both views have the same name' do
      view1 = Viewr::View.new(view_doc_with_dependencies)
      view2 = Viewr::View.new(view_doc_with_dependencies)
      view1.should eql(view2)
      view1.hash.should == view2.hash
    end
  end

end

