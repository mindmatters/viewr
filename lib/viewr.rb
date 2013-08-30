require_relative "viewr/version"
require_relative "viewr/view"
require_relative "viewr/view_runner"
require_relative "viewr/view_adapter/postgres"

module Viewr
  def self.run_views(connection, method, view_files_path)
    adapter = ViewAdapter::Postgres.new(connection)
    runner = ViewRunner.new(adapter)

    viewfiles = File.join(view_files_path, '*.yml')
    Dir.glob(viewfiles).each do |viewfile|
      runner << View.new_from_yaml_file(viewfile)
    end

    runner.run_all(method)
  end
end
