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

H254 and AAC
------------

p = Profile.new
p.category = "Flash h246"
p.title = "Medium"
p.width = 320
p.height = 240
p.extname = ".mp4"
p.command = "ffmpeg -i $input_file$ -acodec libfaac -ar 48000 -ab 64k -ac 2 -b 256K -vcodec libx264 -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -coder 1 -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -subq 5 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -threads 4 $resolution_and_padding$ -y $output_file$"
p.save

For iPhones
-----------

p = Profile.new
p.category = "iPhone"
p.title = "Low"
p.width = 320
p.height = 240
p.extname = ".mp4"
p.command = "ffmpeg -i $input_file$ -f mpegts -acodec libmp3lame -ar 48000 -ab 64k -vcodec libx264 -b 96k -flags +loop -cmp +chroma -partitions +parti4×4+partp8×8+partb8×8 -subq 5 -trellis 1 -refs 1 -coder 0 -me_range 16 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 200k -maxrate 96k -bufsize 96k -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 30 -aspect 320:240 -g 30 -async 2 -threads 4 $resolution_and_padding$ -y $output_file$"
p.save