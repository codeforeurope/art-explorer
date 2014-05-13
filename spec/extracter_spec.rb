require 'spec_helper'

describe CollectionData::Extracter do
  before :all do
    FileUtils.mkdir_p('tmp/full')
    FileUtils.mkdir_p('tmp/thumb')
  end

  describe '.extract' do
    before :all do
      CollectionData::Extracter.extract(file: 'spec/support/example.zip', out_path: 'tmp')
    end

    it 'should process the images in the given .zip file into thumbnails' do
      Dir.glob('tmp/thumb/*/*/*.jpg').length.should == 15
    end

    it 'should process the images in the given .zip file into fullsize images' do
      Dir.glob('tmp/full/*/*/*.jpg').length.should == 15
    end
  end

  after :all do
    FileUtils.rm_rf('tmp/full')
    FileUtils.rm_rf('tmp/thumb')
    FileUtils.rm_rf('data.xml')
  end
end
