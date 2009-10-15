## Summary

The Pandastream Cloud service provides a REST API for managing the upload and encoding of your video assets. Requests to the API make use of the GET, POST, PUT and DELETE request methods. All responses are in JSON.

If you're implementing your own library for accessing the API, the [Panda gem](http://github.com/newbamboo/panda_gem) is a good starting point.

## Example flow of a video through Panda

[Animation of upload flow here]

1. A user on your site wants to upload a new video. You create a form on your site which includes the Flash file upload component.
1. The users selects a video file and submits the form, the Flash upload component hijacks the form and immediately sends the video file directly to Pandastream Cloud.
1. Panda verifies the upload and displays a progress bar as the file is uploaded.
1. Panda receives the file and the video is added to the encoding queue.
1. The Flash upload component is replaced with a hidden form field, containing the id of the new video in your Pandastream Cloud account.
1. The form is then submitted to its destination on your site.
1. Once the video has been encoded, Panda sends a second notification to your application.

## API Reference

All requests should be sent to api.pandastream.com. The exception to this rule is client file uploads which must be sent to upload.pandastream.com which is specially optimized for handling large file uploads.

### Videos

#### GET /videos.json

##### Parameters

    account_key: 32aa8390-b6f6-012a-2162-0017f22c2d49

##### Responses

    Status: 200 OK
    
    Array of videos in format described above for a single video.
- - - 
    Status: 401 Unauthorized



#### POST api.pandastream.com/videos.json

Creates and empty video which a file can then be upload to.

##### Parameters

    account_key: 32aa8390-b6f6-012a-2162-0017f22c2d49

##### Responses

    Status: 200 OK
    
    --- 
    :video: 
      :id: a92fdd10-b6f6-012a-a860-0017f22c2d49
- - - 
    Status: 401 Unauthorized

### Display video upload form
#### GET upload.pandastream.com/videos/_id_/form (html only)

The page returned will contain a form to allow the user to upload a video with the corresponding id. It is suggested that this page is displayed in either an iframe or a popup window. Whilst uploading, a progress bar will keep the users informed of the upload.

Once completed, the user will be redirected to the "Upload redirect url" defined in your Panda config. If setting this is left blank the user will be redirected to a default thank you page.

### Upload video file
#### POST upload.pandastream.com/videos/_id_/upload.(html|yaml|xml)

It's recommended that you use the form described above (which submits to this resource), but if required (such as from within Flash) the file can be submitted directly.

##### Parameters

    file: The video file

##### Responses

    Status: 200 OK

If the video id is not found the following status is returned.

    Status: 404 Not Found

When calling using either yaml or xml formats, there are several different error response which may be returned.

* **NoFileSubmitted**: No file parameter was submitted (check your form's html if you're not using the default Panda form)
* **FormatNotRecognised**: The video format is not supported or the video could not be read.
* **InternalServerError**: There was a internal error. This error will be logged and resolved as soon as possible.

All are returned in the following format.

    Status: 500
    
    ---
    :error: ErrorMessage

### Get details
#### GET api.pandastream.com/videos/_id_.json

Retrieve details for a specific video. Included in the response will be all of its encodings and their current statuses.

The status of a video may be one of the following: 
* **empty**: video has been created but the actual video file has yet to be uploaded
* **original**: video has had a file uploaded to it

The status of an encoding may be one of the following: 
* **queued**: video is waiting in queue for processing
* **processing**: the encoding is currently being encoded
* **success**: the encoding was successful
* **error**: there was an error encoding or handling the video

##### Responses

    Status: 200 OK
    
    --- 
    :video: 
      :width: 320
      :duration: 15900
      :screenshot: bac01bf0-503a-012b-1406-123138002145.flv.jpg
      :original_filename: sneezing_panda.flv
      :height: 240
      :status: original
      :thumbnail: bac01bf0-503a-012b-1406-123138002145.flv_thumb.jpg
      :encodings: 
      - :video: 
          :encoded_at: 2008-08-19 16:35:53 +00:00
          :width: 320
          :duration: 15900
          :profile_title: Flash video SD
          :screenshot: c2e83ee0-503a-012b-1407-123138002145.flv.jpg
          :original_filename: sneezing_panda.flv
          :height: 240
          :status: success
          :thumbnail: c2e83ee0-503a-012b-1407-123138002145.flv_thumb.jpg
          :parent: bac01bf0-503a-012b-1406-123138002145
          :profile: 82d587f0-43cf-012b-13f4-123138002145
          :encoding_time: 10
          :filename: c2e83ee0-503a-012b-1407-123138002145.flv
          :id: c2e83ee0-503a-012b-1407-123138002145
      :filename: bac01bf0-503a-012b-1406-123138002145.flv
      :id: bac01bf0-503a-012b-1406-123138002145
- - -
    Status: 404 Not Found

## Callbacks

When the state of a video changes, Panda will notify your application with a callback. A POST request is made to the "State update url" defined in your Panda config (note that the $id part of this url will be replaced with the id of the video whose status has changed). The request will be attempted a maximum of 5 times, after which time it will be logged as an error and you will be notified (the max number of retries can be set in the Panda config).

### Example callback
#### POST http://mysite/videos/_id_/state

##### Parameters

    --- 
    :video: 
      :width: 320
      :duration: 15900
      :screenshot: bac01bf0-503a-012b-1406-123138002145.flv.jpg
      :original_filename: sneezing_panda.flv
      :height: 240
      :status: original
      :thumbnail: bac01bf0-503a-012b-1406-123138002145.flv_thumb.jpg
      :encodings: 
      - :video: 
          :encoded_at: 2008-08-19 16:35:53 +00:00
          :width: 320
          :duration: 15900
          :profile_title: Flash video SD
          :screenshot: c2e83ee0-503a-012b-1407-123138002145.flv.jpg
          :original_filename: sneezing_panda.flv
          :height: 240
          :status: success
          :thumbnail: c2e83ee0-503a-012b-1407-123138002145.flv_thumb.jpg
          :parent: bac01bf0-503a-012b-1406-123138002145
          :profile: 82d587f0-43cf-012b-13f4-123138002145
          :encoding_time: 10
          :filename: c2e83ee0-503a-012b-1407-123138002145.flv
          :id: c2e83ee0-503a-012b-1407-123138002145
      :filename: bac01bf0-503a-012b-1406-123138002145.flv
      :id: bac01bf0-503a-012b-1406-123138002145

##### Responses

When sending a notification Panda will check the response status code, and if it's not a 200 the notification will be logged as a failed.

## API Authentication

The Pandastream Cloud API requires all requests must also be signed to ensure they are valid and authenticated. For GET and DELETE requests the additional parameters must be url encoded and added to the parameters in the url. When making a POST or PUT request they should be included in the usual parameters payload submitted.

The `access\_key` and `secret\_key` used to authenticate the request are provided when you sign up for your Pandastream Cloud account. Your keys can always be found by logging in to your account by visiting [account.pandastream.com](http://account.pandastream.com)

A correctly signed request contains the following additional parameters:

    access_key: Provided when you sign up for Pandastream Cloud
    timestamp: Current time in iso8601 format
    signature: HMAC signature generated as described below

The `signature` is generated using the following method:

1. Create a `canonical\_querystring` by url encoding all of the parameters and the values, and joining them into one string using the `=` character to separate keys and their values, and the `&` character to separate the key value pairs. 

A typical `canonical\_querystring` might look as follows: `account_key=85f8dbe6-b998-11de-82e1-001ec2b5c0e1&timestamp=2009-10-15T15%3A38%3A42%2B01%3A00` ... other parameters such as those in the POST request would also be added to this string.

2. Construct the `string\_to\_sign` by concatenating the HTTP verb (GET, POST, PUT or DELETE), hostname (api.pandastream.com or upload.pandastream.com), request uri (e.g. /videos.json) and `canonical\_querystring` with newlines (\\n).

An example of a typical `string\_to\_sign`:

    GET
    api.pandastream.com
    /videos.json
    account_key=85f8dbe6-b998-11de-82e1-001ec2b5c0e1&timestamp=2009-10-15T15%3A38%3A42%2B01%3A00

3. Lastly, to generate the final `signature`, using **HMAC SHA256** encode the complete `string\_to\_sign` using your `secret\_key` as the key.