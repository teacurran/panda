TODO: turn into proper documentation

Start with ami-b10dead8

ssh in to it then run:

gem update --system
gem install gemcutter
gem tumble

gem uninstall uuid greatseth-rvideo
gem install uuidtools -v 1.0.3
gem install ruby-hmac sinatra aws jeweler echoe open4 --no-ri --no-rdoc

cd /mnt

git clone git://github.com/newbamboo/simple_record.git
cd simple_record; rake install; cd ..

git clone git://github.com/newbamboo/aasm.git
cd aasm; rake gem; gem install pkg/aasm-2.1.1.gem; cd ..

git clone git://github.com/dctanner/rvideo.git
cd rvideo; rake install; cd ..

git clone git://github.com/adamwiggins/rest-client.git
cd rest-client; rake install

gem install hoe activesupport newgem --no-ri --no-rdoc
git clone git://github.com/newbamboo/panda_gem.git
cd panda_gem; git checkout -b sinatra origin/sinatra; rake gem; gem install pkg/panda-0.0.2.gem --no-ri --no-rdoc; cd ..

rm -rf panda
git clone git://github.com/newbamboo/panda.git
cd panda
git checkout -b sinatra origin/sinatra
mkdir log

# iPhone segmenter

http://www.ioncannon.net/programming/452/iphone-http-streaming-with-ffmpeg-and-an-open-source-segmenter/

apt-get install libbz2-dev libbz2-1.0