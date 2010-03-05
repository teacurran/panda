class Notification
  class NotificationError < StandardError; end

  include DataMapper::Resource

  property :id, Serial
  property :mode, Enum[:http_post, :email]
  property :uri, String
  property :state, String
  property :body, Yaml
  property :retry_count, Integer, :default => 0
  property :last_retried_at, DateTime
  property :sent_at, DateTime

  class << self
    def notify_all!
      pending_notifications.each do |notification|
        notification.send_notification!
      end
    end

    def pending_notifications
      all(
        :sent_at => nil,
        :retry_count.lte => Panda::Config[:notification_retries].to_i
      ).select {|n| n.retry? }
    end
    
    def add_video(video)
      create(
        :state => video.status,
        :mode => :http_post,
        :uri => video.parent_video.state_update_url,
        :body => {"video" => video.parent_video.show_response.to_yaml}
      )
    end

    def add_program_error(msg)
      create(
        :mode => :email,
        :uri => Panda::Config[:notification_email],
        :body => {:message => msg}
      )
    end
  end

  def send_notification!
    begin
      Merb.logger.info "Sending notification to #{uri}"
      if send("send_#{mode}_notification!")
        self.sent_at = Time.now
      else
        self.retry_count += 1
        self.last_retried_at = Time.now
        if retry_count >= Panda::Config[:notification_retries].to_i
          # Send a notification of the failure ONLY AFTER we've retried enough times.
          send("notify_#{mode}_failure")
        end
      end
      save
    end
  end

  def retry?
    last_retried_at.nil? || last_retried_at < Time.now - (Panda::Config[:notification_frequency] * retry_count)
  end
  
  private
  
  def send_email_notification!
    ErrorSender.email(uri, "notification error", body.is_a?(String) ? body : body.to_yaml)
  end
  
  def notify_email_failure
    Merb.logger.error("notification error", "Error sending #{mode} notification:
      EMAIL
      ==================================================
      #{uri}

      #{body.inspect}
      ==================================================
      ".gsub(/\n */,"\n")
    )
  end
  
  def send_http_post_notification!
    begin
      our_uri = URI.parse(uri)
      http = Net::HTTP.new(our_uri.host, our_uri.port)
      req = Net::HTTP::Post.new(our_uri.path)
      if our_uri.user and our_uri.password
        req.basic_auth our_uri.user, our_uri.password
      end
      req.form_data = body
      response = http.request(req)

      return response.code.to_i == 200
    rescue Object => e
      Merb.logger.error "ERROR Posting to #{uri}: #{e.inspect}\n#{e.backtrace[0..14].join("\n")}"
      # Any problems, return false.
      # Could have issue with ruby's Timeout class...?
      return false
    end
  end
  
  def notify_http_post_failure
    ErrorSender.email_and_log("notification error", "Error sending #{mode} notification:
      REQUEST
      ==================================================
      #{uri}

      #{body.inspect}
      ==================================================
      ".gsub(/\n */,"\n")
    )
  end
end
