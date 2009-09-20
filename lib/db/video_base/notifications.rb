module VideoBase
  module Notifications
    def notification_wait_period
      (Panda::Config[:notification_frequency] * self.notification.to_i)
    end

    def time_to_send_notification?
      return true if self.last_notification_at.nil?
      Time.now > (self.last_notification_at + self.notification_wait_period)
    end

    def send_notification
      raise "You can only send the status of encodings" unless self.encoding?

      self.last_notification_at = Time.now
      begin
        self.parent_video.send_status_update_to_client
        self.notification = 'success'
        self.save
        Log.info "Notification successfull"
      rescue
        # Increment num retries
        if self.notification.to_i >= Panda::Config[:notification_retries]
          self.notification = 'error'
        else
          self.notification = self.notification.to_i + 1
        end
        self.save
        raise
      end
    end

    def send_status_update_to_client
      Log.info "Sending notification to #{self.get_state_update_url}"

      params = {"video" => self.show_response.to_yaml}

      uri = URI.parse(self.get_state_update_url)
      http = Net::HTTP.new(uri.host, uri.port)

      req = Net::HTTP::Post.new(uri.path)
      req.form_data = params
      response = http.request(req)

      unless response.code.to_i == 200# and response.body.match /ok/
        ErrorSender.log_and_email("notification error", "Error sending notification for parent video #{self.id} to #{self.get_state_update_url} (POST)

  REQUEST PARAMS
  #{"="*60}\n#{params.to_yaml}\n#{"="*60}

  RESPONSE
  #{response.code} #{response.message} (#{response.body.length})
  #{"="*60}\n#{response.body}\n#{"="*60}")

        raise NotificationError
      end
    end
  end
end