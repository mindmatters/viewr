require_relative "viewr/version"
require_relative "viewr/function"
require_relative "viewr/view"
require_relative "viewr/schema_object_runner"
require_relative "viewr/database_adapter"

module Viewr

  def self.create_all(connection, view_files_path, function_files_path)
    runner = self.setup_runner(connection, view_files_path, function_files_path)
    runner.create_all
  end

  def self.drop_all(connection, view_files_path, function_files_path)
    runner = self.setup_runner(connection, view_files_path, function_files_path)
    runner.drop_all
  end

  def self.recreate_all(connection, view_files_path, function_files_path)
    runner = self.setup_runner(connection, view_files_path, function_files_path)
    runner.drop_all
    runner.create_all
  end

  def self.setup_runner(connection, view_files_path, function_files_path)
    adapter = DatabaseAdapter.new(connection)
    runner = SchemaObjectRunner.new

    self.load_view_specs(view_files_path, runner, adapter)
    self.load_function_specs(function_files_path, runner, adapter)

    runner
  end

  def self.load_view_specs(path, runner, database_adapter)
    view_files = File.join(path, '*.yml')
    Dir.glob(view_files).each do |view_file|
      view_specification = IO.read(view_file)
      runner << View.new_from_yaml(view_specification, database_adapter)
    end
  end

  def self.load_function_specs(path, runner, database_adapter)
    function_files = File.join(path, '*.yml')
    Dir.glob(function_files).each do |function_file|
      function_specification = IO.read(function_file)
      runner << Function.new_from_yaml(function_specification, database_adapter)
    end
  end
end
