# Video.each_successful_encoding do |video|
cutoff_date = Time.parse('2010-04-01')
Video.each do |video|
  if video.created_at > cutoff_date
    begin
      Notification.add_video(video)
      puts "Renotifying for #{video.key} (#{video.created_at})"
    rescue
      puts "!! No Parent for video ##{video.key}"
    end
  else
    print "."
  end
end
