require 'pg'
require 'sequel'


module Viewr
  module RailsHelpers

    def self.internal_views_create(env)
      puts "Creating views and functions for #{env} ..."

      database = sequel_connection(env)
      Viewr::create_all(database, view_files_path, function_files_path)
    ensure
      database.disconnect
    end

    def self.internal_views_drop(env)
      puts "Dropping views and functions for #{env} ..."

      database = sequel_connection(env)
      Viewr::drop_all(database, view_files_path, function_files_path)
    ensure
      database.disconnect
    end

    def self.environments
    end

    private

    def self.sequel_connection(env)
      config = database_config[env]
      Sequel.postgres(config)
    end

    def self.database_config
      filename = File.join(Rails.root, 'config', 'database.yml')
      @@database_yml_contents ||= YAML.load(ERB.new(File.read(filename)).result)
    end

    def self.view_files_path
      File.join(Rails.root, 'db', 'views')
    end

    def self.function_files_path
      File.join(Rails.root, 'db', 'functions')
    end
  end
end
