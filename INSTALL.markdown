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

## Run the merb processes

    merb -p 4000
    merb -r bin/encoder.rb -p 5001 -e encoder
    merb -r bin/notifier.rb -p 6001 -e notifier
