module Viewr
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/db.rake"
    end
  end
end
