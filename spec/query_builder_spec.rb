require 'spec_helper'

describe QueryBuilder do
  describe '#query' do
    context 'unfiltered' do
      let(:builder) {
        QueryBuilder.new({
          query: 'foo',
          from: 0,
          size: 100
        })
      }

      it 'should build the correct elasticsearch query' do
        builder.query.should == {
          query: {query_string: {query: "foo"}},
          facets: {type: {terms: {field: "type", size: 999}}, subject: {terms: {field: "subject", size: 999}}},
          from: 0,
          size: 100
        }
      end
    end
  end
end
