require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './elasticsearch'

require './collection_data/importer'

module CollectionData
  def self.FIELDS
    [
        {xpath: 'atom[@name="irn"]', fieldname: 'irn'},
        {xpath: 'atom[@name="TitAccessionNo"]', fieldname: 'accession_number'},
        {xpath: 'table[@name="Group1"]/tuple/atom[@name="NamFirst"]', fieldname: 'first_name'},
        {xpath: 'table[@name="Group1"]/tuple/atom[@name="NamMiddle"]', fieldname: 'middle_name'},
        {xpath: 'table[@name="Group1"]/tuple/atom[@name="NamLast"]', fieldname: 'last_name'},
        {xpath: 'table[@name="Group1"]/tuple/atom[@name="NamSuffix"]', fieldname: 'suffix'},
        {xpath: 'table[@name="Group1"]/tuple/atom[@name="NamFullName"]', fieldname: 'fullname'},
        {xpath: 'table[@name="Group1"]/tuple/atom[@name="NamOrganisation"]', fieldname: 'organisation'},
        {xpath: 'table[@name="Group1"]/tuple/atom[@name="CreRole"]', fieldname: 'role'},
        {xpath: 'tuple[@name="AccAccessionLotRef"]/atom[@name="SummaryData"]', fieldname: 'accession_summary'},
        {xpath: 'tuple[@name="AccAccessionLotRef"]/atom[@name="AcqCreditLine"]', fieldname: 'purchased'},
        {xpath: 'table[@name="Group2"]/tuple/atom[@name="CreDateCreated"]', fieldname: 'created_on'},
        {xpath: 'table[@name="Group2"]/tuple/atom[@name="CreEarliestDate"]', fieldname: 'earliest_created_on'},
        {xpath: 'table[@name="Group2"]/tuple/atom[@name="CreLatestDate"]', fieldname: 'latest_created_on'},
        {xpath: 'atom[@name="TitObjectName"]', fieldname: 'object_name'},
        {xpath: 'atom[@name="TitMainTitle"]', fieldname: 'title'},
        {xpath: 'atom[@name="TitSeriesTitle"]', fieldname: 'series_title'},
        {xpath: 'atom[@name="TitCollectionTitle"]', fieldname: 'collection_title'},
        {xpath: 'table[@name="PhyMedium_tab"]/tuple/atom[@name="PhyMedium"]', fieldname: 'medium'},
        {xpath: 'atom[@name="PhySupport"]', fieldname: 'support'},
        {xpath: 'table[@name="Group3"]/tuple/atom[@name="PhyType"]', fieldname: 'physical_type'},
        {xpath: 'table[@name="Group3"]/tuple/atom[@name="PhyHeight"]', fieldname: 'height'},
        {xpath: 'table[@name="Group3"]/tuple/atom[@name="PhyWidth"]', fieldname: 'width'},
        {xpath: 'table[@name="Group3"]/tuple/atom[@name="PhyUnitLength"]', fieldname: 'unit'},
        {xpath: 'atom[@name="PhyDescription"]', fieldname: 'description'},
        {xpath: 'atom[@name="CrePrimaryInscriptions"]', fieldname: 'inscription'},
        {xpath: 'atom[@name="CreProvenance"]', fieldname: 'provenance'},
        {xpath: 'table[@name="BibBibliographyRef_tab"]/tuple/atom[@name="SummaryData"]', fieldname: 'bibliography'},
        {xpath: 'table[@name="MulMultiMediaRef_tab"]/tuple/atom[@name="irn"]', fieldname: 'media_irn'},
        {xpath: 'table[@name="TitCollectionGroup_tab"]/tuple/atom[@name="TitCollectionGroup"]', fieldname: 'tags', multivalued: true},
        {xpath: 'table[@name="PhyContentAnalysis_tab"]/tuple/atom[@name="PhyContentAnalysis"]', fieldname: 'content_tags', multivalued: true},
        {xpath: 'table[@name="CreSubjectClassification_tab"]/tuple/atom[@name="CreSubjectClassification"]', fieldname: 'subject_tags', multivalued: true}
      ]
  end

  def self.is_item_node?(xml_fragment)
  !!xml_fragment.at_xpath('atom[@name="TitAccessionNo"]')
end

  def self.clear
    CollectionItem.index.delete
  end
end