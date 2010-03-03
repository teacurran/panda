class ErrorSender
  def self.email_and_log(subj, text)
    email(subj, text)
    Merb.logger.error "#{subj}\n#{text}"
  end

  def self.email(subj, text, to=nil)
    to, subj, text = subj, text, to if !to.nil?
    if Panda::Config[:notification_email].nil? or Panda::Config[:noreply_from].nil?
      begin
        m = Merb::Mailer.new(
          :to      => to || Panda::Config[:notification_email],
          :from    => Panda::Config[:noreply_from],
          :subject => "Panda [#{Panda::Config[:account_name]}] #{subj}",
          :text    => text
        )
        m.deliver!
        Merb.logger.info "Email notification sent to #{Panda::Config[:notification_email]}"
      rescue Object
        Merb.logger.error "!! Error - Email notification FAILED to send to #{Panda::Config[:notification_email]}!"
        return false
      end
      return true
    else
      return false
    end
  end
end
