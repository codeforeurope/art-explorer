class CollectionItem
  include Tire::Model::Persistence

  self.include_root_in_json = false

  property :irn, type: 'integer'
  property :accession_number
  property :first_name
  property :middle_name
  property :last_name
  property :suffix
  property :fullname
  property :organisation
  property :role
  property :accession_summary
  property :purchased
  property :created_on, type: 'integer'
  property :earliest_created_on, type: 'integer'
  property :latest_created_on, type: 'integer'
  property :object_name
  property :title
  property :series_title
  property :collection_title
  property :medium
  property :support
  property :physical_type
  property :height, type: 'double'
  property :width, type: 'double'
  property :unit
  property :description
  property :inscription
  property :provenance
  property :bibliography
  property :media_irn, type: 'integer'
  property :tags
  property :content_tags
  property :subject_tags

  def as_json
    super(except: ['id'])
  end
end