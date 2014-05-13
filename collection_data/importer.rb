module CollectionData
  class Importer
    def initialize(converter)
      @converter = converter
      @buffer = []
    end

    def import(filename)
      file = File.open(filename, 'r')
      reader = Nokogiri::XML::Reader(file)
      reader.each do |node|
        fragment = Nokogiri::XML.fragment(node.inner_xml)
        next unless is_item_node?(fragment) # skip unless node is an object to import
        process(fragment)
        flush if flush?
      end
      flush unless @buffer.empty?
    end

    def process(fragment)
      @buffer << @converter.convert(fragment)
    end

    class << self
      def clear_index
        Search.clear
      end

      def create_index
        Search.create_index(body: {
          mappings: {}.merge(CollectionItem.index_mapping)
        })
      end

      def import(filename)
        converter = Converter.new
        importer = Importer.new(converter)
        importer.import(filename)
      end
    end

    private

    def is_item_node?(xml_fragment)
      !!xml_fragment.at_xpath('atom[@name="TitAccessionNo"]')
    end

    def flush?
      (@buffer.size >= 1000)
    end

    def flush
      logger.info "Importing #{@buffer.length} records"
      Search.bulk_index(@buffer, type: CollectionItem.index_type, id: :identifier)
      @buffer = []
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
