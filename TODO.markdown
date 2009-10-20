
Private beta release
--------------------
* [done in new-bamboo/simple_record fork] Rename update and created to have _at in simple record
* [done] Test post /videos
* [done] Fix the output .m3u8 file from the segmenter so it doesn't include the dir path in it and just uses the filename. http://www.ioncannon.net/programming/452/iphone-http-streaming-with-ffmpeg-and-an-open-source-segmenter/comment-page-1/#comments
* [done] Api docs
* Switch to right-aws s3 which has better http perf
* Add video with url instead of post

** Test Rails app **

* Encode per video not per encoding so that we don't fetch the master file from s3 multiple times
* Non-flash file upload. Write js (extract stuff from jquery.form.js) which submits file in an iframe and processes response.
** Ability to get status of upload via api (for html upload)
** Support errors in upload_redirect_url like http://mypandasite.com/videos/done?id=$id&error=$error&error_message=$error_message
** Use nginx with file upload plugin so ruby doesn't touch any video data: e.g. http://www.motionstandingstill.com/nginx-upload-awesomeness/2008-08-13/
* Rails app screencast
* SimpleDB pagination for index get requests
* Raise RecordNotFound when using SimpleDB (right now we just return nil)
* upload.pandastream.com and api.pandastream.com
* Store uploader as daemon
* Move git clone git://github.com/dctanner/rvideo.git to newbamboo account
* Move panda_gem to jeweler
* Thumbnails
* Upload to other S3

Beta R2
-------
* Migration script
* Split api auth into a separate gem
* Look into yamdi instead of flvtool
* Callbacks with api auth
* Custom params passthrough
* PHP and Python libs
* pandastream.com/support
* JW player bitrate switching http://developer.longtailvideo.com/trac/wiki/FlashOverview#BitrateSwitching and http://developer.longtailvideo.com/trac/wiki/FlashFormats

Plugins
-------
* Cloudfront http://docs.amazonwebservices.com/AmazonCloudFront/latest/GettingStartedGuide/

Other todo
----------
* API signatures blog post
* Investigate Amazon sdb gem