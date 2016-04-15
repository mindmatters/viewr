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

    self.load_views(view_files_path, runner, adapter)
    self.load_functions(function_files_path, runner, adapter)

    runner
  end

  def self.load_views(path, runner, database_adapter)
    view_files = File.join(path, '*.yml')
    Dir.glob(view_files).each do |view_file|
      runner << View.new_from_yaml(IO.read(view_file), database_adapter)
    end
  end

  def self.load_functions(path, runner, database_adapter)
    function_files = File.join(path, '*.yml')
    Dir.glob(function_files).each do |function_file|
      runner << Function.new_from_yaml(IO.read(function_file), database_adapter)
    end
  end

end
