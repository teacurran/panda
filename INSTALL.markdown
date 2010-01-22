# To Install Panda

This was taken from a combination of the following documents:

* [http://pandastream.com/docs/getting_started](http://pandastream.com/docs/getting_started)
* [http://pandastream.com/docs/local_installation](http://pandastream.com/docs/local_installation)

Another possibly helpful resource:

* [http://gist.github.com/raw/99384/e0399a42d521c63964f503c91d84b5cd24af4b4e/local_installation.markdown](http://gist.github.com/raw/99384/e0399a42d521c63964f503c91d84b5cd24af4b4e/local_installation.markdown)

## Download and checkout Panda itself

    git clone git://github.com/dyn/panda.git
    cd panda
    # git checkout origin/stable
    git checkout -b origin/auto-install

## Run the automatic stuff

    ./script/setup

## Configure Panda

    cp config/panda_init.rb.example config/panda_init.rb
    # CHANGE AT LEAST THE ITEMS IN ALL CAPS
    nano panda_init.rb

    cp config/mailer.rb.example config/mailer.rb
    nano mailer.rb

## Bootstrap some necessary pieces

    # Sets up the default flash players
    Store.set('player.swf', 'public/player.swf')
    Store.set('swfobject2.js', 'public/javascripts/swfobject2.js')
    Store.set('expressInstall.swf', 'public/expressInstall.swf')
    
    # Set up an Admin user
    u = User.new
    u.login = 'admin'
    u.email = 'YOUR_EMAIL'
    u.set_password('password')
    u.save
    
    # Create an encoding profile. More can be found at the first url at the top of this document.
    Profile.create!(:title => "Flash video SD",  :container => "flv", :video_bitrate => 300, :audio_bitrate => 48, :width => 320, :height => 240, :fps => 24, :position => 0, :player => "flash")
