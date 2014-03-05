module CollectionData
  class Importer
    attr_accessor :filename

    def initialize(filename)
      self.filename = filename
    end

    def import
      file = File.open(self.filename, 'r')
      reader = Nokogiri::XML::Reader(file)
      convertor = CollectionData::Convertor.new
      reader.each do |node|
        fragment = Nokogiri::XML.fragment(node.inner_xml)
        next unless is_item_node?(fragment) # skip unless node is an object to import

        data = convertor.convert(fragment)
        item = CollectionItem.create(data)
        logger.info "Imported '#{item.title}' by #{item.fullname}"
      end
    end

    private

    def is_item_node?(xml_fragment)
      !!xml_fragment.at_xpath('atom[@name="TitAccessionNo"]')
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
