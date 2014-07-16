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
          query: {query_string: {query: "foo"}},
          from: 0,
          size: 100
        }
      end
    end
  end
end
