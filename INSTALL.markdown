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

## Starting / Stopping Daemons

    rake start_daemons

### Installing remotely

You will have to configure config/panda\_init.rb on the server, and optionally config/error\_messages.yml.

There are no system daemons to install. There is just a cron job, called "immortalize" that monitors the
processes, restarts them when they quit, and notifies you when they go down more than 5 times in an hour.
First you will need the "immortalize" rubygem installed on the server:

    sudo gem install immortalize

Then you can install it to a cron job by running:

    cap deploy:immortalize\_daemons
