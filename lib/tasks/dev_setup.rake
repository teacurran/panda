namespace :dev do
  desc "Sets up dependencies and configures nginx, which should be running correctly out of the box once installed!"
  task :setup => [:gems, :install_libjpeg, :install_gd2, :nginx] do
    puts "Setup complete!"
  end

  desc "Install the rubygems Panda depends on."
  task :gems do
    if !File.writable?("/")
      warn "Please run this command as root!"
      exit
    end

    system("sudo env PATH=$PATH gem install --no-ri --no-rdoc RubyInline amazon_sdb aws-s3 flvtool2")
  end

  task :install_libjpeg do
    if !File.writable?("/")
      warn "Please run this command as root!"
      exit
    end
    system("mkdir -p ~/src; chmod 777 ~/src")
    Dir.chdir("#{ENV['HOME']}/src")
    if File.exists?("jpeg-6b/Makefile")
      puts "Already installed libjpeg. (to reinstall please `rm -rf ~/src/jpeg-6b`)"
    else
      puts "Installing libjpeg..."
      system("curl -O ftp://ftp.aai.ee/pub/unix/jpegsrc.v6b.tar.gz; tar zxvf jpegsrc.v6b.tar.gz") unless File.exists?("jpegsrc.v6b.tar.gz")
      system("sudo mkdir -p /usr/local/man/man1/")
      system("cd jpeg-6b; ./configure '--with-jpeg=/usr/local' '--with-png=/usr/local' '--with-zlib-dir=/usr/local' && make && sudo make install && sudo make install-lib; cd ..")
    end
  end

  task :install_gd2 do
    if !File.writable?("/")
      warn "Please run this command as root!"
      exit
    end
    # Install gd2. apt-get, port, whatever works for your system
    installer = `which port`.chomp
    installer = `which apt-get`.chomp if installer == ''
    # system("sudo env PATH=$PATH \"#{installer}\" install gd2 -y")
    system("sudo env PATH=$PATH \"#{installer}\" install ffmpeg -y")

    # More gd stuff
    system("mkdir -p ~/src; chmod 777 ~/src")
    Dir.chdir("#{ENV['HOME']}/src")
    if File.exists?("gd-2.0.35/Makefile")
      puts "Already installed gd (to reinstall please `rm -rf ~/src/gd-2.0.35`)"
    else
      puts "Installing gd..."
      system("curl -O http://www.libgd.org/releases/gd-2.0.35.tar.gz; tar zxvf gd-2.0.35.tar.gz") unless File.exists?("gd-2.0.35.tar.gz")
      system("cd gd-2.0.35 && ./configure && make && sudo make install && cd ..")
    end
  end

  desc "Install and Configure nginx."
  task :nginx => [:"nginx:install", :"nginx:configure"]

  namespace :nginx do
    desc "Install nginx with http-upload-progress support."
    task :install do
      if !File.writable?("/")
        warn "Please run this command as root!"
        exit
      end

      system("mkdir -p ~/src; chmod 777 ~/src")
      Dir.chdir("#{ENV['HOME']}/src")

      puts "Installing nginx..."
      # Installs PCRE, whatever that is. Seems to be a dependency for nginx though.
      if File.exists?("pcre-7.7/Makefile")
        puts "Already installed PCRE (to reinstall please `rm -rf ~/src/pcre-7.7`)"
      else
        puts "Installing PCRE..."
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
      if !File.writable?("/")
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
