require 'timeout'
 
module RunLater
  @@run_now = false
  @@queue = ::Queue.new
 
  def self.queue
    @@queue
  end
 
  def self.run_now?
    @@run_now
  end
 
  def self.run_now=(run_now)
    @@run_now = run_now
  end
 
  module InstanceMethods
    def run_later(&block)
      if RunLater.run_now?
        block.call
      else
        @@run_later ||= RunLater::Worker.instance
        RunLater.queue << block
      end
    end
  end
      
  class Worker
    attr_accessor :thread
    attr_accessor :logger
    
    def initialize
      @thread = Thread.new {
        trap :INT do
          RunLater::Worker.shutdown
          exit
        end
 
        loop {
          process_queue
        }
      }
    end
    
    def self.instance
      @worker ||= begin
        w = RunLater::Worker.new
        w.logger = Logger.new(STDOUT) # TODO: output to log for each video up, which is uploaded to S3 if there's an exception
        w
      end
    end
 
    def self.shutdown
      begin
        Timeout::timeout 10 do
          loop {break unless instance.thread[:running]}
        end
      rescue Timeout::Error
        logger.error("Worker thread timed out. Forcing shutdown.")
      ensure
        instance.thread.kill!
      end
    end
 
    def self.cleanup
      begin
        Timeout::timeout 10 do
          loop do
            break unless instance.thread[:running]
            # When run in Passenger, explicitly pass control to another thread
            # which will in return hand over control to the worker thread.
            # However, it doesn't work in Passenger 2.1.0, since it removes
            # all its classes before handing the request over to Rails.
            Thread.pass if defined?(::Passenger)
          end
        end
      rescue Timeout::Error
        logger.warn("Worker thread takes too long and will be killed.")
        instance.thread.kill!
        @worker = RunLater::Worker.new
      end
    end
    
    def process_queue
      begin
        while block = RunLater.queue.pop
          Thread.pass
          Thread.current[:running] = true
          block.call
          Thread.current[:running] = false
        end
      rescue Exception => e
        logger.error("Worker thread crashed, retrying. Error was: #{e}")
        Thread.current[:running] = false
        retry
      end
    end
  end
end

Sinatra::Base.send(:include, RunLater::InstanceMethods)