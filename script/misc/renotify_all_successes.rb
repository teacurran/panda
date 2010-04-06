class SimpleDB
  class Base
    def self.each(expr="", query_options={})
      raise ArgumentError, "must include a block!" unless block_given?
      result_set = self.domain.query(query_options.merge({:expr => expr}))
      begin
        result_set.each do |r|
          v = self.new(r.key, r.attributes, false)
          yield v
        end
      end while result_set.instance_variable_get(:@next_token) != "" && result_set = self.domain.query(query_options.merge({:expr => expr, :next_token => result_set.instance_variable_get(:@next_token)}))
    end
  end
end

Video.each("['status' = 'success']") do |video|
  Notification.add_video(video) rescue puts "!! No Parent for video ##{video.key}"
end
