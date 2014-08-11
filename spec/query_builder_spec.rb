require 'spec_helper'

describe QueryBuilder do
  describe '#query' do
    context 'simple' do
      let(:builder) {
        QueryBuilder.new({
          query: 'foo',
          from: 0,
          size: 100
        })
      }

      it 'should build the correct elasticsearch query' do
        builder.query.should == {
          query: {bool: {should: [
            {query_string: {query: "foo", default_operator: "AND", default_field: "type", boost: 8}},
            {query_string: {query: "foo", default_operator: "AND", default_field: "subject", boost: 8}},
            {query_string: {query: "foo", default_operator: "AND", default_field: "creator", boost: 4}},
            {query_string: {query: "foo", default_operator: "AND", default_field: "title", boost: 2}},
            {query_string: {query: "foo", default_operator: "AND", default_field: "description", boost: 1}},
            {query_string: {query: "foo", default_operator: "AND", default_field: "_all", boost: 0.5}}]}},
          from: 0,
          size: 100,
          sort: { identifier: { order: :asc }}
        }
      end
    end
  end
end
