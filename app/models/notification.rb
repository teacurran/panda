class Notification
  class NotificationError < StandardError; end

  include DataMapper::Resource

  property :id, Serial
  property :mode, Enum[:http_post, :email]
  property :uri, String
  property :body, Yaml
  property :retry_count, Integer, :default => 0
  property :last_retried_at, DateTime
  property :sent_at, DateTime

  class << self
    def pending_notifications
      all(
        :sent_at => nil,
        :retry_count.lt => Panda::Config[:notification_retries].to_i
      ).select {|n|
        # Select only fresh ones or those that have waited long enough to retry
        n.last_retried_at.nil? || n.last_retried_at < Time.now - (Panda::Config[:notification_frequency] * n.retry_count)
      }
    end
    
    def add_video(video)
      create(
        :mode => :http_post,
        :uri => video.state_update_url,
        :body => {"video" => video.show_response.to_yaml}
      )
    end

    def add_program_error(msg)
      create(
        :mode => :email,
        :uri => Panda::Config[:notification_email],
        :body => msg
      )
    end
  end

  def send_notification!
    begin
      Merb.logger.info "Sending notification to #{self.state_update_url}"
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

  private
  
  def send_email_notification!
    ErrorSender.email(uri, "notification error", body)
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
      uri = URI.parse(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path)
      if uri.user and uri.password
        req.basic_auth uri.user, uri.password
      end
      req.form_data = body
      response = http.request(req)

      return response.code.to_i == 200
    rescue Object
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

      RESPONSE
      ==================================================
      #{response.code} #{response.message}
      Content-Length: #{response.body.length}

      #{response.body}
      ==================================================
      ".gsub(/\n */,"\n")
    )
  end
end
