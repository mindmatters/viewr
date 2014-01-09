require_relative "viewr/version"
require_relative "viewr/view"
require_relative "viewr/schema_object_runner"
require_relative "viewr/database_adapter/postgres"

module Viewr
  def self.run_views(connection, method, view_files_path)
    adapter = DatabaseAdapter::Postgres.new(connection)
    runner = SchemaObjectRunner.new(adapter)

    viewfiles = File.join(view_files_path, '*.yml')
    Dir.glob(viewfiles).each do |viewfile|
      runner << View.new_from_yaml_file(viewfile)
    end

    runner.run_all(method)
  end
end
