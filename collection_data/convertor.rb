module CollectionData
  class Convertor
    include DataSmash::Convertor

    def self.with_xpath(xpath, fieldname)
      ->(xml, data) {
        data[fieldname] = xml.at_xpath(xpath).text rescue ''
        data
      }
    end

    convert with_xpath('atom[@name="irn"]', :irn)
    convert with_xpath('atom[@name="TitAccessionNo"]', :accession_number)
    convert with_xpath('table[@name="Group1"]/tuple/atom[@name="NamFirst"]', :first_name)
    convert with_xpath('table[@name="Group1"]/tuple/atom[@name="NamMiddle"]', :middle_name)
    convert with_xpath('table[@name="Group1"]/tuple/atom[@name="NamLast"]', :last_name)
    convert with_xpath('table[@name="Group1"]/tuple/atom[@name="NamSuffix"]', :suffix)
    convert with_xpath('table[@name="Group1"]/tuple/atom[@name="NamFullName"]', :fullname)
    convert with_xpath('table[@name="Group1"]/tuple/atom[@name="NamOrganisation"]', :organisation)
    convert with_xpath('table[@name="Group1"]/tuple/atom[@name="CreRole"]', :role)
    convert with_xpath('table[@name="Group2"]/tuple/atom[@name="CreDateCreated"]', :created_on)
    convert with_xpath('table[@name="Group2"]/tuple/atom[@name="CreEarliestDate"]', :earliest_created_on)
    convert with_xpath('table[@name="Group2"]/tuple/atom[@name="CreLatestDate"]', :latest_created_on)
    convert with_xpath('atom[@name="TitObjectName"]', :object_name)
    convert with_xpath('atom[@name="TitMainTitle"]', :title)
    convert with_xpath('atom[@name="TitSeriesTitle"]', :series_title)
    convert with_xpath('atom[@name="TitCollectionTitle"]', :collection_title)
    convert with_xpath('table[@name="PhyMedium_tab"]/tuple/atom[@name="PhyMedium"]', :medium)
    convert with_xpath('atom[@name="PhySupport"]', :support)
    convert with_xpath('table[@name="Group3"]/tuple/atom[@name="PhyType"]', :physical_type)
    convert with_xpath('table[@name="Group3"]/tuple/atom[@name="PhyHeight"]', :height)
    convert with_xpath('table[@name="Group3"]/tuple/atom[@name="PhyWidth"]', :width)
    convert with_xpath('table[@name="Group3"]/tuple/atom[@name="PhyUnitLength"]', :unit)
    convert with_xpath('atom[@name="PhyDescription"]', :description)
  end
end
