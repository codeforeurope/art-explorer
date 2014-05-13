module CollectionData
  class ImageProcessor
    def process_image(opts={})
      filename = opts.fetch(:filename)
      out_path = opts.fetch(:out_path)
      in_path = opts.fetch(:in_path)

      im = VIPS::Image.new(in_path)
      path = File.join(out_path, 'thumb', filename)
      save_image(im, 320, path)
      path = File.join(out_path, 'full', filename)
      save_image(im, 1200, path)
    end

    private

    def save_image(image, max_size, path)
      d = [image.x_size, image.y_size].max
      shrink = [d/max_size.to_f, 1].max
      image = image.shrink(shrink)
      out_dir = File.dirname(path)
      out_path = "#{File.basename(path, '.*')}.jpg"
      FileUtils.mkdir_p(out_dir)
      image.write(File.join(out_dir, out_path))
    end

    def get_reader(filename, data)
      {
        '.jpg' => VIPS::JPEGReader.new(data),
        '.tif' => VIPS::TIFFReader.new(data) #, shrink: 2)
      }[ File.extname(filename).downcase ]
    end
  end
end
