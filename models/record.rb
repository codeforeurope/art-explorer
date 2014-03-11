class Record
  class MalformedTags < StandardError;; end

  include Mongoid::Document

  field :irn
  field :uid
  field :tags, type: Array

  def update_tags(tags_string)
    begin
      CSV.parse(tags_string) do |tags|
        tags.map!(&:strip)
        update_attribute(:tags, tags)
      end
    rescue CSV::MalformedCSVError => e
      raise MalformedTags.new("Couldn't parse the given tags")
    end
  end
end
