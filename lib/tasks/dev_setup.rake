namespace :dev do
  desc "Sets up nginx, which should be running correctly out of the box once installed!"
  task :setup => [:nginx] do
    puts "Setup complete!"
  end

  desc "Install and Configure nginx."
  task :nginx => [:"nginx:install", :"nginx:configure"]

  namespace :nginx do
    desc "Install nginx with http-upload-progress support."
    task :install do
      if !File.writable?("/usr/local/conf/nginx.conf")
        warn "Please run this command as root!"
        exit
      end

      system("mkdir -p ~/src")
      Dir.chdir("#{ENV['HOME']}/src")

      puts "Installing nginx..."
      # Installs PCRE, whatever that is. Seems to be a dependency for nginx though.
      if File.exists?("pcre-7.7/Makefile")
        puts "Already installed PCRE (to reinstall please `rm -rf ~/src/pcre-7.7`)"
      else
        system("curl -O http://ftp.exim.llorien.org/pcre/pcre-7.7.tar.gz; tar xvfz pcre-7.7.tar.gz") unless File.exists?("pcre-7.7.tar.gz")
        system("cd pcre-7.7; ./configure --prefix=/usr/local && make && sudo make install; cd ..")
      end

      # Installs nginx with http-upload-progress support.
      if File.exists?("nginx-0.6.32/Makefile")
        puts "Already installed nginx (to reinstall please `rm -rf ~/src/nginx-0.6.32`)"
      else
        system("wget http://github.com/masterzen/nginx-upload-progress-module/tarball/v0.7; tar xvfz masterzen-nginx-upload-progress-module-ac62a29.tar.gz") unless File.exists?("masterzen-nginx-upload-progress-module-ac62a29.tar.gz")
        system("curl -O http://sysoev.ru/nginx/nginx-0.6.32.tar.gz; tar xvfz nginx-0.6.32.tar.gz") unless File.exists?("nginx-0.6.32.tar.gz")
        system("cd nginx-0.6.32; ./configure --prefix=/usr/local --with-http_ssl_module --add-module=$UPM && make && sudo make install && growlnotify -m \"Done Installing NGINX\"; cd ..")
      end

      # If /usr/local/sbin is not in $PATH, notify the user that they need it in their path.
      unless ENV['PATH'].split(':').include?('/usr/local/sbin')
        puts "Your PATH needs to include `/usr/local/sbin'. Please add this to your path (~/.bash_profile OR ~/.profile, and ~/.bashrc) and then hit ENTER."
        $stdin.readline
        ENV['PATH'] << '/usr/local/sbin'
      end
      Dir.chdir(RAILS_ROOT)

      Rake::Task["dev:nginx:restart"].invoke
    end

    desc "Configure nginx for me automatically."
    task :configure do
      if !File.writable?("/usr/local/conf/nginx.conf")
        warn "Please run this command as root!"
        exit
      end

      nginx_config = File.read('/usr/local/conf/nginx.conf')
      if nginx_config =~ /proxy_pass http:\/\/127.0.0.1:4000;/ && nginx_config =~ /track_uploads proxied 30s;/
        puts "Nginx is already configured."
      else
        puts "Configuring nginx..."

        $stdout << "Please enter the host name for configuring nginx: "
        $stdout.flush
        $hostname = $stdin.readline.dup.chomp

        # Open textmate to configure nginx: open the real config and the sample.
        nginx_config = File.read("lib/tasks/dev-setup-sample-configs/nginx.conf")
        nginx_config.gsub!(/HOSTNAME/, $hostname)
        File.open('/usr/local/conf/nginx.conf', 'w') {|f| f << nginx_config }
        # Have user hit ENTER when they have nginx configured...

        Rake::Task["dev:nginx:restart"].invoke
      end
    end

    desc "Just starts or restarts nginx properly."
    task :restart do
      nginx_pid = `ps -A|grep nginx`.match(/^\D*(\d+)/)[1] rescue nil
      if nginx_pid
        puts "Restarting nginx..."
        system("sudo kill -HUP #{nginx_pid}")
      else
        puts "Starting nginx..."
        system("sudo nginx")
      end
    end
  end
end
