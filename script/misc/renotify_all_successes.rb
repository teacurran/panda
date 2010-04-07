# Video.each_successful_encoding do |video|
cutoff_date = Time.parse('2010-04-01')
Video.each do |video|
  if video.created_at > cutoff_date
    puts "Renotifying for #{video.key} (#{video.created_at})"
    Notification.add_video(video) rescue puts "!! No Parent for video ##{video.key}"
  else
    print "."
  end
end
