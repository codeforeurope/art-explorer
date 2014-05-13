module CollectionData
  class Extracter
    def self.extract(opts={})
      filename = opts.fetch(:file)
      out_path = opts.fetch(:out_path)

      Zip::File.open(filename) do |zip|
        zip.entries.each do |entry|
          puts entry.name
          process_image_entry(entry, out_path) if is_image?(entry)
          process_xml_entry(entry) if is_xml?(entry)
        end
      end
    end

    def self.process_image_entry(entry, out_path)
      filename = entry.name.gsub('data/multimedia/', '')
      in_path = File.join('tmp', File.basename(entry.name))
      entry.extract(in_path)
      processor = CollectionData::ImageProcessor.new
      processor.process_image(filename: filename, in_path: in_path, out_path: out_path)
      FileUtils.rm(in_path)
    end

    def self.process_xml_entry(entry)
      FileUtils.rm('data.xml') if File.exists?('data.xml')
      entry.extract('data.xml')
    end

    def self.is_image?(entry)
      ['.jpg', '.tif'].include?(File.extname(entry.name).downcase)
    end

    def self.is_xml?(entry)
      (File.extname(entry.name) == '.xml')
    end
  end
end
