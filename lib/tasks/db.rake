require_relative '../viewr/rails_helpers'


namespace :db do
  namespace :views do

    desc "create SQL views"
    task create: :environment do
      Viewr::RailsHelpers::internal_views_create(Rails.env)
    end

    desc "drop SQL views"
    task drop: :environment do
      Viewr::RailsHelpers::internal_views_drop(Rails.env)
    end
  end
end
