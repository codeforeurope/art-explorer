require 'spec_helper'

describe CollectionData::ImageProcessor do
  let(:processor) { CollectionData::ImageProcessor.new }

  describe '#process_image' do
    before(:all) do
      FileUtils.mkdir_p('tmp/thumb')
      FileUtils.mkdir_p('tmp/full')
    end

    context 'given a jpeg' do
      let(:in_path) { 'spec/support/kitten.jpg' }

      it 'should create a JPEG thumbnail' do
        processor.process_image(filename: 'a/b/c/kitten.jpg', in_path: in_path, out_path: 'tmp')
        thumb = VIPS::Image.jpeg('tmp/thumb/a/b/c/kitten.jpg')
        thumb.y_size.should == 320
      end

      it 'should create a JPEG large web image' do
        processor.process_image(filename: 'a/b/c/kitten.jpg', in_path: in_path, out_path: 'tmp')
        thumb = VIPS::Image.jpeg('tmp/full/a/b/c/kitten.jpg')
        thumb.y_size.should == 1200
      end
    end

    context 'given a tiff' do
      let(:in_path) { 'spec/support/example.tif' }

      it 'should create a JPEG thumbnail' do
        processor.process_image(filename: 'a/b/c/example.tif', in_path: in_path, out_path: 'tmp')
        thumb = VIPS::Image.jpeg('tmp/thumb/a/b/c/example.jpg')
        thumb.y_size.should == 320
      end

      it 'should create a JPEG large web image' do
        processor.process_image(filename: 'a/b/c/example.tif', in_path: in_path, out_path: 'tmp')
        thumb = VIPS::Image.jpeg('tmp/full/a/b/c/example.jpg')
        thumb.y_size.should == 1200
      end
    end

    after(:all) do
      FileUtils.rm_rf('tmp/thumb')
      FileUtils.rm_rf('tmp/full')
    end
  end
end
