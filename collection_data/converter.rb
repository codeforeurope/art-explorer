module CollectionData
  class Converter
    include DataSmash::Convertor

    def self.with_xpath(xpath, fieldname, opts={})
      multivalued = opts.fetch(:multivalued, false)

      ->(xml, data) {
        value = (multivalued ? xml.xpath(xpath).map(&:text) : xml.at_xpath(xpath).text) rescue nil
        data[fieldname] = value if value.present?
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
      if start_date
        date = start_date.text.to_i
        data[:earliest] = date if date > 0
      end
      data
    }
    convert ->(xml,data) {
      end_date = xml.at_xpath('table[@name="Group2"]/tuple/atom[@name="CreLatestDate"]')
      if end_date
        date = end_date.text.to_i
        data[:latest] = date if date > 0
      end
      data
    }
    convert ->(xml, data) {
      data[:latest] ||= data[:earliest] if data[:earliest]
      data[:earliest] ||= data[:latest] if data[:latest]
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
      subjects = xml.xpath('table[@name="CreSubjectClassification_tab"]/tuple/atom[@name="CreSubjectClassification"]').map(&:text)
      data[:subject].concat(subjects)
      data
    }
    convert ->(xml, data) {
      place_name = xml.xpath('table[@name="Group4"]/tuple/atom').map(&:text).join(', ')
      data[:coverage] = { placename: place_name } if (place_name && place_name != '')
      data
    }
    convert ->(xml,data) {
      xml.xpath('table[@name="MulMultiMediaRef_tab"]/tuple').each do |node|
        next unless node.at_xpath('atom[@name="AdmPublishWebNoPassword"]').try(:text) == 'Yes'
        data[:images] ||= []
        path = node.at_xpath('atom[@name="Multimedia"]').text
        path.gsub!(/jpg|JPG|tif|TIF/, 'jpg')
        acknowledgement = node.at_xpath('atom[@name="DetRights"]').try(:text)
        data[:images] << { path: path, acknowledgement: acknowledgement }
      end
      data
    }
    convert ->(xml,data) {
      xml.xpath('table[@name="RigRightsRef_tab"]/tuple').each do |node|
        next unless node.at_xpath('atom[@name="RigRequiresAcknowledgement"]').try(:text) == 'Yes'
        data[:acknowledgement] = node.at_xpath('atom[@name="RigAcknowledgement"]').text
      end
      data
    }
    convert ->(xml, data) {
      xml.xpath('tuple[@name="LocCurrentLocationRef"]').each do |node|
        next unless node.at_xpath('atom[@name="AdmPublishWebNoPassword"]').try(:text) == 'Yes'
        location = node.at_xpath('atom[@name="SummaryData"]').text
        data[:location] = location
      end
      data
    }
    convert ->(xml, data) {
      xml.xpath('tuple[@name="AccAccessionLotRef"]').each do |node|
        next unless node.at_xpath('atom[@name="AdmPublishWebNoPassword"]').try(:text) == 'Yes'
        credit = node.at_xpath('atom[@name="AcqCreditLine"]').text
        data[:acquisition_credit] = credit
      end
      data
    }
  end
end
