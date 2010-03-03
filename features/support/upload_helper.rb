module Dyn
  module FeatureHelper
    module UploadHelpers
      def upload_video(file="features/fixtures/default_video.mov")
        [file, "features/fixtures/#{file}"].each {|file| break if File.exists?(file)}
        video_file = Rack::Test::UploadedFile.new(file)
        webrat.post "/api/videos", "file" => video_file
        if webrat.response.body =~ /\{\"status\":\"(\d+)\",\"message\":\"([^\"]+)\"/
          # Inject the response status and message from the iframe JSON response. :)
          webrat.response.instance_variable_set(:@status, $1.to_i)
          webrat.response.instance_variable_set(:@message, $2)
        end
      end
    end
  end
end

World(Dyn::FeatureHelper::UploadHelpers)
