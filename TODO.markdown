* [done in new-bamboo/simple_record fork] Rename update and created to have _at in simple record
* [done] Test post /videos
* Fix the output .m3u8 file from the segmenter so it doesn't include the dir path in it and just uses the filename. http://www.ioncannon.net/programming/452/iphone-http-streaming-with-ffmpeg-and-an-open-source-segmenter/comment-page-1/#comments
* API signatures + blog post on how to do it
* SimpleDB pagination for index get requests
* Raise RecordNotFound when using SimpleDB (right now we just return nil)
* Non-flash file upload. Write js (extract stuff from jquery.form.js) which submits file in an iframe and processes response.
* Use nginx with file upload plugin so ruby doesn't touch any video data: e.g. http://www.motionstandingstill.com/nginx-upload-awesomeness/2008-08-13/
* Split api auth into a separate gem
* Move git clone git://github.com/dctanner/rvideo.git to newbamboo account
* Move panda_gem to jeweler
* Look into yamdi instead of flvtool