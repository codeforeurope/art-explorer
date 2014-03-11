require 'spec_helper'

describe Record do
  let(:record) { Record.create(irn: '123456', uid: 'test') }

  describe '#update_tags' do
    context 'given a comma-separated set of tags' do
      it 'should store each tag separately' do
        record.update_tags('foo, bar, baz')
        record.tags.should =~ ['foo', 'bar', 'baz']
      end

      it 'should handle double quotes appropriately' do
        record.update_tags('foo,"bar bar",baz')
        record.tags.should =~ ['foo', 'bar bar', 'baz']
      end

      it 'should raise an appropriate error when given a bad string of tags' do
        expect { record.update_tags('foo, "bar", baz') }.to raise_error(Record::MalformedTags)
      end
    end
  end
end
