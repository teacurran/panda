Panda
=====

Panda is an open source solution for video uploading, encoding and streaming.

Please see [pandastream.com](http://pandastream.com/) for an introduction and lots of documentation.

Information beyond this point is aimed at people who want to contribute to panda and / or understand how it works.

How does Panda work?
====================

1. Video is uploaded to panda
2. Panda checks the video's metadata, uploads the raw file to S3 and adds it to the encoding queue
3. The encoder application picks the encoding job off the queue when it's free and encodes the video to all possible formats
4. Panda sends a callback to your web application notifying you the video has been encoded
5. You use the appropriate S3 url of the encoding to embed the video

Installation and setup
======================

There are two options for running Panda. You can either the use the prebuild AMI which includes all of the software required to run Panda. Or if you wish run it locally on own your own server, you can follow the [local installation guide](http://pandastream.com/docs/local_installation).

Example Profiles
================

The category is a special attribute, for example if you set it to 'iphone-stream' the video will be split up into segments which are all uploaded to the store along with the .m3u8 playlist required for streaming the segments.

H254 and AAC
------------

p = Profile.new
p.title = "Flash h264 (Medium)"
p.category = "flash"
p.width = 320
p.height = 240
p.extname = ".mp4"
p.command = "ffmpeg -i $input_file$ -acodec libfaac -ar 48000 -ab 64k -ac 2 -b 256K -vcodec libx264 -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -coder 1 -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -subq 5 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -threads 4 $resolution_and_padding$ -y $output_file$"
p.save

FLV
------------

p = Profile.new
p.title = "Flash FLV (Medium)"
p.category = "flash"
p.width = 320
p.height = 240
p.extname = ".flv"
p.command = "ffmpeg -i $input_file$ -ar 22050 -ab 64k -f flv -b 256k $resolution_and_padding$ -y $output_file$\nflvtool2 -U $output_file$"
p.save

For streaming on iPhones
-----------

For details see:  http://www.ioncannon.net/programming/452/iphone-http-streaming-with-ffmpeg-and-an-open-source-segmenter

You will need to ensure your videos_domain option in the Panda config is only a domain name.

p = Profile.new
p.title = "iPhone stream (Medium)"
p.category = "iphone-stream"
p.width = 320
p.height = 240
p.extname = ".ts"
p.command = "ffmpeg -i $input_file$ -t 100 -f mpegts -acodec libmp3lame -ar 48000 -ab 64k -s $width$x$height$ -vcodec libx264 -b 96k -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -subq 5 -trellis 1 -refs 1 -coder 0 -me_range 16 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 200k -maxrate 96k -bufsize 96k -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 30 -aspect $width$:$height$ -g 30 -async 2 -threads 4 $resolution_and_padding$ -y $output_file$\nsegmenter $output_file$ 10 $private_tmp_path$/$id$ $private_tmp_path$/$id$.m3u8 http://$videos_domain$/"
p.save

Setting up upload from your app
===============================

TODO: example jquery uploader

Do it yourself
--------------

POST to /videos with correct API signature
Add in header X-Requested-With, with the value "XMLHttpRequest" (see http://www.insideria.com/2009/04/jqueryserver-side-tip-on-detec.html)