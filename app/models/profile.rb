class Profile < AWS::Record::Base

  set_domain config.sdb_profiles_domain
  properties :title, :player, :container, :width, :height, :video_codec, :video_bitrate, :fps, :audio_codec, :audio_bitrate, :audio_sample_rate, :position, :updated_at, :created_at
  
  def self.warn_if_no_encodings
    if Profile.query.empty?
      Merb.logger.info "PANDA CONFIG ERROR: There are no encoding profiles. You probably forgot to define them. Please see the getting started guide."
    end
  end
end
