class ErrorSender
  def self.log_and_email(subj, text)
    if Panda::Config[:notification_email].nil? or Panda::Config[:noreply_from].nil?
      Log.warn "No notification_email or noreply_from set in panda_init.rb so this error will only written to the log and not emailed."
    else
      m = Merb::Mailer.new :to      => Panda::Config[:notification_email],
                           :from    => Panda::Config[:noreply_from],
                           :subject => "Panda [#{Panda::Config[:account_name]}] #{subj}",
                           :text    => text
      m.deliver!
      Log.info "Error email sent to #{Panda::Config[:notification_email]}"
    end
    
    Log.error text
  end
end