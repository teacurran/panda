YAHOO.util.CrossFrame.onMessageEvent.subscribe(function (type, args, obj) {
  var message = args[0];
  var domain = args[1];
  var json = JSON.parse(message);
  
  if(typeof json.callback == "string"){
    if(typeof json.arguments == "string"){
      eval(json.callback + '(' + json.arguments + ')');
    }else{
      eval(json.callback + '()');
    }
  }
  
});

if(!Remix) var Remix = {};
if(!Remix.Video){
  Remix.Video = {};
}

Remix.Video.upload = function(settings){
  settings = jQuery.extend({
    form: "<form object> - required",
    destination: "http://video.remix.local/proxy.html",
    target: "frames['rw_progress']",
    respondToDestination: "http://yourapp.com/proxy.html",
    respondToTarget: "top"
  }, settings);
  
  // Define callbacks
  if(settings['start']) Remix.Video.start(settings['start']);
  if(settings['progress']) Remix.Video.progress(settings['progress']);
  if(settings['error']) Remix.Video.error(settings['error']);
  if(settings['success']) Remix.Video.success(settings['success']);
  
  // Setup form action
  var form = $(settings.form);
  var action = $(form).attr("action");
  var progress_id = Remix.Video.randomUUID();
  jQuery(form).attr("action", action.split(/\?/)[0] + "?X-Progress-ID=" + progress_id);
  
  // Setup cross-frame callback method and arguments
  var callback = "Remix.Video.trackUploadProgress";
  var arguments = JSON.stringify({
    progress_id: progress_id, 
    respondToDestination: settings['respondToDestination'],
    respondToTarget: settings['respondToTarget']
  });
  
  // Communicate across frames
  YAHOO.util.CrossFrame.send(
    settings.destination, 
    settings.target, 
    JSON.stringify({callback: callback, arguments: arguments})
  );
  
  return true;
};

Remix.Video.start = function(callback){
  if(typeof callback == "function"){
    this._startingCallback = callback;
  } else if(this._startingCallback) {
    this._startingCallback(arguments);
  }
};

Remix.Video.progress = function(callback){
  if(typeof callback == "function"){
    this._progressCallback = callback;
  } else if(this._progressCallback) {
    this._progressCallback(arguments);
  }
};

Remix.Video.error = function(callback){
  if(typeof callback == "function"){
    this._errorCallback = callback;
  } else if(this._errorCallback) {
    this._errorCallback(arguments);
  }
};


Remix.Video.success = function(callback){
  if(typeof callback == "function"){
    this._successCallback = callback;
  } else if(this._successCallback) {
    this._successCallback(arguments);
  }
};


/* randomUUID.js - Version 1.0
* 
* Copyright 2008, Robert Kieffer
* 
* This software is made available under the terms of the Open Software License
* v3.0 (available here: http://www.opensource.org/licenses/osl-3.0.php )
*
* The latest version of this file can be found at:
* http://www.broofa.com/Tools/randomUUID.js
*
* For more information, or to comment on this, please go to:
* http://www.broofa.com/blog/?p=151
*
* Create and return a "version 4" RFC-4122 UUID string. */
Remix.Video.randomUUID = function(){
  var s = [], itoh = '0123456789ABCDEF';

  // Make array of random hex digits. The UUID only has 32 digits in it, but we
  // allocate an extra items to make room for the '-'s we'll be inserting.
  for (var i = 0; i <36; i++) s[i] = Math.floor(Math.random()*0x10);

  // Conform to RFC-4122, section 4.4
  s[14] = 4;  // Set 4 high bits of time_high field to version
  s[19] = (s[19] & 0x3) | 0x8;  // Specify 2 high bits of clock sequence

  // Convert to hex chars
  for (var i = 0; i <36; i++) s[i] = itoh[s[i]];

  // Insert '-'s
  s[8] = s[13] = s[18] = s[23] = '-';

  return s.join('');
};

Remix.Video.trackUploadProgress = function(settings){
  var progress_id = settings['progress_id'];
  var respondToDestination = settings['respondToDestination'];
  var respondToTarget = settings['respondToTarget'];
  var started = false;
  
  var sendMsg = function(callback, args){
    YAHOO.util.CrossFrame.send(
      respondToDestination,
      respondToTarget,
      JSON.stringify({callback: callback, arguments: JSON.stringify(args) })
    );
  };
  
  settings = jQuery.extend({ interval: 1800 }, settings);

  var timer = setInterval(function() { 
    jQuery.ajax({
      url: "http://video.remix.local/progress",
      dataType: "jsonp",
      beforeSend: function(xhr) {
        xhr.setRequestHeader("X-Progress-ID", progress_id);
      },
      error: function(data){
        clearInterval(timer);
        sendMsg("Remix.Video.error", data);
      },
      complete: function(xhr, statusText) {
        // no-op, handled by success
      },
      success: function(data) {
        if(data.state == "starting" && !started) {
          // only trigger start callback once
          started = true
          sendMsg("Remix.Video.start", data);
        } else if(data.state == "done"){
          clearInterval(timer);
          sendMsg("Remix.Video.success", data);
        } else if(data.state == "error"){
          clearInterval(timer);
          sendMsg("Remix.Video.error", data);
        } else {
          if(!started){
            started = true;
            sendMsg("Remix.Video.start", data);
          }
          sendMsg("Remix.Video.progress", data);
        }
      }
    });
  }, settings['interval']/3);
};
