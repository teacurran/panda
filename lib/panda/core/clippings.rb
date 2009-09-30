module Panda::Core
  module Clippings
    # Returns configured number of 'middle points', for example [25,50,75]
    def thumbnail_percentages
      n = Panda::Config[:choose_thumbnail]

      return [50] if n == false

      # Interval length
      interval = 100.0 / (n + 1)
      # Points is [0,25,50,75,100] for example
      points = (0..(n + 1)).map { |p| p * interval }.map { |p| p.to_i }

      # Don't include the end points
      return points[1..-2]
    end

    def generate_thumbnail_selection
      self.thumbnail_percentages.each do |percentage|
        self.clipping(percentage).capture
        self.clipping(percentage).resize
      end
    end

    def upload_thumbnail_selection
      self.thumbnail_percentages.each do |percentage|
        self.clipping(percentage).upload_to_store
        self.clipping(percentage).delete_locally
      end
    end
    
    def clipping(position = nil)
      Clipping.new(self, position)
    end

    def clippings
      self.thumbnail_percentages.map do |p|
        Clipping.new(self, p)
      end
    end
  end
end