* [done in new-bamboo/simple_record fork] Rename update and created to have _at in simple record
* [done] Test post /videos
* Fix the output .m3u8 file from the segmenter so it doesn't include the dir path in it and just uses the filename. http://www.ioncannon.net/programming/452/iphone-http-streaming-with-ffmpeg-and-an-open-source-segmenter/comment-page-1/#comments
* API signatures blog post
* Non-flash file upload. Write js (extract stuff from jquery.form.js) which submits file in an iframe and processes response.
* Split api auth into a separate gem
* Look into yamdi instead of flvtool

Private beta release
--------------------
* Api docs
* Rails app screencast
* SimpleDB pagination for index get requests
* Raise RecordNotFound when using SimpleDB (right now we just return nil)
* Use nginx with file upload plugin so ruby doesn't touch any video data: e.g. http://www.motionstandingstill.com/nginx-upload-awesomeness/2008-08-13/
* upload.pandastream.com and api.pandastream.com
* Store uploader as daemon
* Move git clone git://github.com/dctanner/rvideo.git to newbamboo account
* Move panda_gem to jeweler
* Thumbnails
* Upload to other S3

Beta R2
-------
* Migration script
* Callbacks with api auth
* Custom params passthrough
* PHP and Python libs
* pandastream.com/support

Plugins
-------
* Cloudfront