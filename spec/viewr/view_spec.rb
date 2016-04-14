# coding: utf-8
require_relative '../shared_examples/database_object'
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
      expect(adapter).to receive(:run).with('SQL STATEMENT')

      view.create
    end
  end

  describe '#drop' do
    it 'should drop the view using the adapter' do
      expect(adapter).to receive(:drop_view).with('bar')

      view.drop
    end
  end
end
