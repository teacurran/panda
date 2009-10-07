module Panda
  class ConfigError < RuntimeError; end

  class Config
    class << self
      def defaults
        @defaults ||= {
          :private_tmp_path       => "/tmp",
          
          :thumbnail_height_constrain => 125,
          
          :notification_retries   => 6,
          :notification_frequency => 10,
          
          :database               => :simpledb,
          :sdb_domain_prefix      => "panda2_",
          :sdb_base_url           => "http://sdb.amazonaws.com/",
          
          :encoding_log_dir       => File.dirname(__FILE__) + "/../log"
        }
      end
      
      def environment=(env)
        @environment = env
      end
      
      def use(env)
        @configuration ||= {}
        @configuration[env] ||= {}
        yield @configuration[env]
      end

      def [](key)
        @configuration[@environment][key] || defaults[key]
      end
      
      def []=(key,val)
        @configuration[@environment][key] = val
      end
      
      def check
        check_present(:api_key, "Please specify a secret api_key")
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