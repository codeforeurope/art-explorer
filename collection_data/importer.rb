module CollectionData
  class Importer
    attr_accessor :filename

    def initialize(filename)
      self.filename = filename  
    end

    def import
      file = File.open(self.filename, 'r')
      reader = Nokogiri::XML::Reader(file)
      reader.each do |node|
        fragment = Nokogiri::XML.fragment(node.inner_xml)
        next unless fragment.at_xpath('atom[@name="TitAccessionNo"]') # skip unless node is an object to import

        attrs = {}
        CollectionData.FIELDS.each do |field|
          fieldname = field[:fieldname]
          attrs[fieldname] = value_for_field(field, fragment)
        end

        item = CollectionItem.create(attrs)
        logger.info "Imported '#{item.title}' by #{item.fullname}"
      end
    end

    private

    def value_for_field(field, fragment)
      xpath = field[:xpath]
      value = nil
      if field[:multivalued]
        value = fragment.xpath(xpath).map(&:text) rescue []
      else
        value = fragment.at_xpath(xpath).text rescue ''
      end
      value
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end