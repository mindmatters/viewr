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

    SchemaObjectRunner.new(
      self.load_views(view_files_path, adapter) +
        self.load_functions(function_files_path, adapter)
    )
  end

  def self.load_views(path, database_adapter)
    view_files = File.join(path, '*.yml')
    Dir.glob(view_files).map do |view_file|
      View.new_from_yaml(IO.read(view_file), database_adapter)
    end
  end

  def self.load_functions(path, database_adapter)
    function_files = File.join(path, '*.yml')
    Dir.glob(function_files).map do |function_file|
      Function.new_from_yaml(IO.read(function_file), database_adapter)
    end
  end

end
