module Panda
  class ConfigError < RuntimeError; end

  class Config
    class << self
      def defaults
        @defaults ||= {
          :account_name           => "My Panda Account",
          
          :private_tmp_path       => Merb.root / "videos",
          :public_tmp_path        => Merb.root / "public" / "tmp",
          :public_tmp_url         => "/tmp",
          
          :thumbnail_height_constrain => 125,
          :choose_thumbnail       => false,
          
          :notification_retries   => 6,
          :notification_frequency => 10,
          
          :sdb_base_url           => "http://sdb.amazonaws.com/"
        }
      end
      
      def use
        @configuration ||= {}
        yield @configuration
      end

      def [](key)
        @configuration[key] || defaults[key]
      end
      
      def []=(key,val)
        @configuration[key] = val
      end
      
      def check
        check_present(:api_key, "Please specify a secret api_key")
        check_present(:upload_redirect_url)
        check_present(:state_update_url)
        
        # %w{}.each do |d|
        #   check_present(d.to_sym)
        # end
      end
      
      def check_present(option, message = nil)
        unless Panda::Config[option]
          m = "Missing required configuration option: #{option.to_s}"
          m += " [#{message}]" if message
          raise Panda::ConfigError, m
        end
      end
    end
  end
end