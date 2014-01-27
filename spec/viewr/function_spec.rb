# coding: utf-8
require_relative '../support/shared_examples_for_database_objects'
require_relative '../../lib/viewr/function'

describe Viewr::Function do

  let(:function_doc) do
    {
      'name' => 'bar',
      'sql' => 'SQL STATEMENT'
    }
  end
  let(:adapter) { double(:adapter) }
  let(:function) { Viewr::Function.new(function_doc, adapter) }

  it_behaves_like 'a database object'

  describe '#create' do
    it 'should run the SQL on the adapter' do
      adapter.should_receive(:run).with('SQL STATEMENT')

      function.create
    end
  end

  describe '#drop' do
    it 'should drop the function using the adapter' do
      adapter.should_receive(:drop_function).with('bar')

      function.drop
    end
  end
end

