require 'spec_helper'

describe CollectionData::Converter do
  let(:node) do
    root = Nokogiri::XML::Document.parse(File.read('spec/support/example_data.xml')).root
    root.at_xpath('/table/tuple')
  end

  describe 'A conversion' do
    let(:conversion) { CollectionData::Converter.new.convert(node) }

    it 'should parse the title correctly' do
      conversion[:title].should == 'An Awesome Hat'
    end

    it 'should skip fields which are empty'

    it 'should set the earliest created date as a number' do
      conversion[:earliest].should == 1920
    end

    it 'should set the latest created date as a number' do
        conversion[:latest].should == 1925
    end

    it 'should skip a date field, given a 0'

    context 'given no creation date' do
      it 'should set neither the earliest or latest created dates'
    end

    it 'should combine the collection group and classification fields into a single array of subjects' do
      conversion[:subject].should == ["costume", "women", "headwear", "period: 20th century", "period: 1920s"]
    end

    it 'should set the placename' do
      conversion[:coverage][:placename].should == 'Europe, United Kingdom, England, London'
    end

    it 'should parse the rights acknowledgement correctly' do
      conversion[:acknowledgement].should == '©Manchester City Galleries'
    end

    it 'should parse the images correctly' do
      image = conversion[:images].first
      image.should == { path: '1/2/3.jpg', acknowledgement: '©Manchester City Galleries' }
    end

    it 'should parse the location correctly' do
      conversion[:location].should == 'Main Gallery'
    end

    it 'should parse the acquisition credit line correctly' do
      conversion[:acquisition_credit].should == 'Transferred from the Royal Manchester Institution.'
    end
  end
end
