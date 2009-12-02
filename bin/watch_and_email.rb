# merb -r "panda/bin/watch_and_email.rb"
# requires Pony gem, install with
# sudo gem install pony --source http://gemcutter.org

require 'rubygems'
require 'pony'

queue_size = Video.queued_encodings.size

puts "Queue size: #{queue_size}"

if  queue_size > 100 
  puts "Queue size too large, emailing notification"
  Pony.mail(:to => 'root@localhost.com', 
            :from => 'panda@localhost.com', 
            :subject => "Panda queue is has #{queue_size} jobs",
            :body => "Panda queue is has #{queue_size} jobs",
            :via => :smtp, 
            :smtp => {
              :host   => 'smtp.yourserver.com',
              :port   => '25',
            })
end