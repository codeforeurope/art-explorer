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
      data = []
      reader.each do |node|
        fragment = Nokogiri::XML.fragment(node.inner_xml)
        next unless is_item_node?(fragment) # skip unless node is an object to import

        data << convertor.convert(fragment)
        logger.info '.'
      end
      logger.info "Importing..."
      Elasticsearch.bulk_index(data, type: CollectionItem.index_type)
      logger.info "Imported #{data.length} records"
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
