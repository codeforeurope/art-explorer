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

      it 'should not contain a filter block' do
        builder.query[:filter].should be_nil
      end
    end

    context 'filtered' do
      let(:titles) { ['bar', 'baz'] }
      let(:terms) { { title: titles.join(', '), type: 'boo' } }
      let(:builder) {
        QueryBuilder.new({
          query: 'foo',
          from: 0,
          size: 100,
          filters: terms
        })
      }

      it 'should include appropriate elasticsearch filters' do
        builder.query[:filter][:terms][:title].should == titles
      end
    end
  end
end
