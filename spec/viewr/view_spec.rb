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

  describe '#initialize' do
    it 'defaults type to :view' do
      view = Viewr::View.new(view_doc, adapter)
      expect(view.type).to eql(:view)
    end

    it 'allows to set type' do
      view = Viewr::View.new(view_doc.merge('type' => 'materialized_views'), adapter)
      expect(view.type).to eql(:materialized_views)
    end
  end

  describe '#create' do
    it 'should run the SQL on the adapter' do
      expect(adapter).to receive(:create_view).with(view)

      view.create
    end
  end

  describe '#drop' do
    it 'should drop the view using the adapter' do
      expect(adapter).to receive(:drop_view).with(view)

      view.drop
    end
  end
end
