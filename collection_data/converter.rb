module CollectionData
  class Converter
    include DataSmash::Convertor

    def self.with_xpath(xpath, fieldname, opts={})
      multivalued = opts.fetch(:multivalued, false)

      ->(xml, data) {
        value = (multivalued ? xml.xpath(xpath).map(&:text) : xml.at_xpath(xpath).text) rescue nil
        data[fieldname] = value if value
        data
      }
    end

    convert with_xpath('atom[@name="TitAccessionNo"]', :identifier)
    convert with_xpath('atom[@name="TitMainTitle"]', :title)
    convert with_xpath('table[@name="Group1"]/tuple/atom[@name="NamFullName"]', :creator)
    convert with_xpath('atom[@name="PhyDescription"]', :description)
    convert with_xpath('table[@name="TitCollectionGroup_tab"]/tuple/atom[@name="TitCollectionGroup"]', :subject, multivalued: true)
    convert ->(xml, data) {
      start_date = xml.at_xpath('table[@name="Group2"]/tuple/atom[@name="CreEarliestDate"]')
      end_date =   xml.at_xpath('table[@name="Group2"]/tuple/atom[@name="CreLatestDate"]')

      data[:date] = {}
      data[:date][:start] = start_date.text if start_date
      data[:date][:end] = end_date.text if end_date
      data
    }
    convert ->(xml,data) {
      data[:title] ||= xml.at_xpath('atom[@name="TitObjectName"]').text
      data
    }
    convert ->(xml, data) {
      type = xml.at_xpath('table[@name="PhyTechnique_tab"]/tuple/atom[@name="PhyTechnique"]')
      data[:type] = type.text.split(',').map(&:strip) if type
      data
    }
    convert ->(xml, data) {
      data[:subject] ||= []
      data[:subject] << xml.xpath('table[@name="CreSubjectClassification_tab"]/tuple/atom[@name="CreSubjectClassification"]').map(&:text)
      data
    }
    convert ->(xml, data) {
      place_name = xml.xpath('table[@name="Group3"]/tuple/atom').map(&:text).join(', ')
      data[:coverage] = { placeName: place_name }
      data
    }
    convert ->(xml,data) {
      xml.xpath('table[@name="MulMultiMediaRef_tab"]/tuple').each do |node|
        next unless node.at_xpath('atom[@name="AdmPublishWebNoPassword"]').text == 'Yes'
        data[:images] ||= []
        path = node.at_xpath('atom[@name="Multimedia"]').text
        path.gsub!(/jpg|JPG|tif|TIF/, 'jpg')
        data[:images] << path
      end
      data
    }
  end
end
