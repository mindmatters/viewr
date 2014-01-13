require_relative "viewr/version"
require_relative "viewr/view"
require_relative "viewr/schema_object_runner"
require_relative "viewr/database_adapter/postgres"

module Viewr
  def self.create_views_and_functions(connection, method, view_files_path, function_files_path)
    adapter = DatabaseAdapter::Postgres.new(connection)
    runner = SchemaObjectRunner.new(adapter)

    view_files = File.join(view_files_path, '*.yml')
    Dir.glob(view_files).each do |view_file|
      runner << View.new_from_yaml_file(view_file)
    end

    function_files = File.join(function_files_path, '*.yml')
    Dir.glob(function_files).each do |function_file|
      runner << Function.new_from_yaml_file(function_file)
    end

    runner.run_all(method)
  end
end
