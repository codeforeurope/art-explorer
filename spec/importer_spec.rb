require 'spec_helper'

describe CollectionData::Importer do
  let(:filename) { 'spec/support/example_data.xml' }
  let(:importer) { CollectionData::Importer.new(filename) }

  it 'should store the filename for later use' do
    importer.filename.should == filename
  end

  describe 'import' do
    let(:logger) { double('Logger', info: true) }

    before do
      importer.stub(:logger).and_return(logger)
    end

    it 'should create a CollectionItem for each entry in the given data' do
      expect{ importer.import; Elasticsearch.refresh }.to change{ CollectionItem.search('*').total }.by(1)
    end

    it 'should populate elasticsearch from the given xml file' do
      importer.import
      Elasticsearch.refresh
      CollectionItem.search("irn:123456").should_not be_empty
    end

    it 'should log each entry during import' do
      logger.should_receive(:info).twice
      importer.import
    end
  end
end
