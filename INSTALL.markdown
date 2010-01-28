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

## Run all of the development setup

    ./script/install_gems
    cp config/mailer.rb.example config/mailer.rb
    sudo env PATH=$PATH rake dev:setup

While that's running, you can open up another terminal and configure Panda:

    rake dev:panda_config_wizard

You can edit config/panda_init.rb further to your liking if you want, or just read it over to make sure the config wizard did its job.

## Run the merb processes

    merb -p 4000
    merb -r bin/encoder.rb -p 5001 -e encoder
    merb -r bin/notifier.rb -p 6001 -e notifier

## Starting / Stopping Daemons

The config/rc-scripts/ directory houses default init scripts for panda, it's encoder, and it's notifier processes.

### Installing locally

The following rake task will copy these into your /etc/init.d/ directory:

  rake dev:install_system_daemons

### Installing remotely

The following cap task will run the above rake task on the remote server:

  cap deploy:install_system_daemons

