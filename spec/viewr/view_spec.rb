# coding: utf-8
require_relative '../support/shared_examples_for_database_objects'
require_relative '../../lib/viewr/view'

describe Viewr::View do

  let(:view_doc) do
    {
      'name' => 'bar',
      'sql' => 'SQL STATEMENT'
    }
  end
  let(:adapter) { double(:adapter) }
  let(:view) { Viewr::View.new(view_doc, adapter) }

  it_behaves_like 'a database object'

  describe '#create' do
    it 'should run the SQL on the adapter' do
      adapter.should_receive(:run).with('SQL STATEMENT')

      view.create
    end
  end

  describe '#drop' do
    it 'should drop the view using the adapter' do
      adapter.should_receive(:drop_view).with('bar')

      view.drop
    end
  end
end
