require 'database_helper'
require_relative '../lib/viewr'

describe Viewr, type: :database do

  it "manages database views and functions" do
    view_files_path = File.expand_path("../fixtures/views/", __FILE__)
    function_files_path = File.expand_path("../fixtures/functions/", __FILE__)

    expect("example_view").not_to exist_as_view
    expect("example_function").not_to exist_as_function

    Viewr.create_all(test_database, view_files_path, function_files_path)

    expect("example_view").to exist_as_view
    expect("example_function").to exist_as_function

    Viewr.drop_all(test_database, view_files_path, function_files_path)

    expect("example_view").not_to exist_as_view
    expect("example_function").not_to exist_as_function
  end

end
