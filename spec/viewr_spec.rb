require_relative '../lib/viewr'
require_relative '../lib/viewr/database_adapter'
require_relative '../lib/viewr/function'
require_relative '../lib/viewr/view'

describe Viewr do

  describe '.create_all' do
    it 'sets up a runner and calls #create_all on it' do
      runner = double(:runner)
      Viewr.should_receive(:setup_runner).with(:connection, :view_files_path, :function_files_path).and_return(runner)
      runner.should_receive(:create_all)

      Viewr.create_all(:connection, :view_files_path, :function_files_path)
    end
  end

  describe '.drop_all' do
    it 'sets up a runner and calls #create_all on it' do
      runner = double(:runner)
      Viewr.should_receive(:setup_runner).with(:connection, :view_files_path, :function_files_path).and_return(runner)
      runner.should_receive(:drop_all)

      Viewr.drop_all(:connection, :view_files_path, :function_files_path)
    end
  end

  describe '.recreate_all' do
    it 'sets up a runner, then drops all database objects, then re-creates them' do
      runner = double(:runner)
      Viewr.should_receive(:setup_runner).with(:connection, :view_files_path, :function_files_path).and_return(runner)
      runner.should_receive(:drop_all).ordered
      runner.should_receive(:create_all).ordered

      Viewr.recreate_all(:connection, :view_files_path, :function_files_path)
    end
  end

  describe '.setup_runner' do
    it 'creates a database object runner, then loads views and functions into it' do
      adapter = double(:database_adapter)
      runner = double(:database_object_runner)
      Viewr::DatabaseAdapter.should_receive(:new).with(:connection).and_return(adapter)
      Viewr::SchemaObjectRunner.should_receive(:new).with(adapter).and_return(runner)
      Viewr.should_receive(:load_views).with(:view_files_path, runner)
      Viewr.should_receive(:load_functions).with(:function_files_path, runner)

      Viewr.setup_runner(:connection, :view_files_path, :function_files_path)
    end
  end

  describe '.load_views' do
    it 'loads all views from the given directory' do
      runner = double(:database_object_runner)
      adapter = double(:database_adapter)
      yaml_data = double(:yaml_data)
      Viewr::View.should_receive(:new_from_yaml).with(
        IO.read('spec/fixtures/views/example_view.yml'), adapter).and_return(yaml_data)
      runner.should_receive(:<<).with(yaml_data)

      Viewr.load_views('spec/fixtures/views', runner, adapter)
    end
  end

  describe '.load_functions' do
    it 'loads all functions from the given directory' do
      runner = double(:database_object_runner)
      adapter = double(:database_adapter)
      yaml_data = double(:yaml_data)
      Viewr::Function.should_receive(:new_from_yaml).with(
        IO.read('spec/fixtures/functions/example_function.yml'), adapter).and_return(yaml_data)
      runner.should_receive(:<<).with(yaml_data)

      Viewr.load_functions('spec/fixtures/functions', runner, adapter)
    end
  end
end
