# You need to create a foo.mpg file in the current directory to run this.
# 
# Conclusion: not significantly faster to capture_frame multiple times on one 
# RVideo object. Also, capturing thumbnails is slow...
# 
# Timings based on a 30s 2.3MB video.

require 'benchmark'
require 'rubygems'
require 'rvideo'

positions = [0,20,40,60,80,100]
n = 4

Benchmark.bm do |x|
  x.report {
    n.times { |i|
      positions.each { |p|
        t = RVideo::Inspector.new(:file => 'foo.mpg', :ffmpeg_binary => $FFMPEG)
        t.capture_frame("#{p}%", "bar_#{i}_#{p}.jpg")
      }
    }
  }
  
  x.report {
    n.times { |i|
      t = RVideo::Inspector.new(:file => 'foo.mpg', :ffmpeg_binary => $FFMPEG)
      positions.each { |p|
        t.capture_frame("#{p}%", "bar2_#{i}_#{p}.jpg")
      }
    }
  }
end

# $ ruby timer.rb 
#       user     system      total        real
#   0.010000   0.120000  19.840000 ( 20.111673)
#   0.020000   0.070000  19.350000 ( 19.678712)
