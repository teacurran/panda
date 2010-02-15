var report_error = function(code, message){
  // Redirect to the error_url with error_code and error_message appended.
  location.href = error_url + (error_url.match(/\?/) ? '&' : '?') + 'error_code=' + code + '&error_message=' + message;
};

jQuery.nginxUploadProgress = function(settings) {
  settings = jQuery.extend({
    interval: 1800,
    progress_bar_id: "progressbar",
    nginx_progress_url: "/progress"
  }, settings);

  var options = { 
    beforeSubmit: function(formData, jqForm, options) {
      $('#uploader').hide();
      $('#uploading').show();
      if(uploading_iframe_url) $('#uploading_notifier_iframe')[0].src = uploading_iframe_url + '?nocache=' + Math.floor(Math.random()*999);
      
      this.timer = setInterval(function() { jQuery.nginxUploadProgressFetch(this, settings['nginx_progress_url'], settings['progress_bar_id'], settings['uuid']); }, settings['interval']/3);
      return true; 
    },
    complete: function(xhr, statusText)  {
      data = $.httpData(xhr, "json");
      if(data.location) location.href = data.location;
      else if(console && console.error) console.error(data);
    },
    dataType: 'json'        // 'xml', 'script', or 'json' (expected server response type)
  };

  // bind form using 'ajaxForm' 
  $('#upload').ajaxForm(options);
};

jQuery.nginxUploadProgress.inum = 0;
jQuery.nginxUploadProgress.last_chunk = 6;
jQuery.nginxUploadProgress.last_percent = 0;

jQuery.nginxUploadProgressFetch = function(e, nginx_progress_url, progress_bar_id, uuid) {
  var bar = $('#'+progress_bar_id);

  // window.console.log("fetcing progress for "+uuid)
  jQuery.nginxUploadProgress.inum++;
  if(jQuery.nginxUploadProgress.inum % 3 == 1){
    var bump = jQuery.nginxUploadProgress.last_chunk / 3;
    bump = jQuery.nginxUploadProgress.last_percent + bump;
    if(jQuery.nginxUploadProgress.last_percent == 100) bump = 100;
    else if(bump > 100) bump = 99;
    bar.width('' + bump + '%');
    return;
  }
  if(jQuery.nginxUploadProgress.inum % 3 == 0) return;

  $.ajax({
    type: "GET",
    url: nginx_progress_url,
    dataType: "json",
    beforeSend: function(xhr) {
      xhr.setRequestHeader("X-Progress-ID", uuid);
      // window.console.log("setting headers: "+uuid)
    },
    complete: function(xhr, statusText) {
      // window.console.log("complete!: "+statusText);
    },
    success: function(upload) {
      /* change the width if the inner progress-bar */
      if (upload.state == 'uploading') {
        var w = Math.floor((upload.received / upload.size)*100);
        jQuery.nginxUploadProgress.last_chunk = w - jQuery.nginxUploadProgress.last_percent;
        jQuery.nginxUploadProgress.last_percent = w;
        bar.width(w + '%');

        // Panda specific
        bar.show();

        // Update ETA
        eta_seconds = ((upload.size / upload.received) * (jQuery.nginxUploadProgress.inum/3)) - (jQuery.nginxUploadProgress.inum/3);

        if (eta_seconds < 60) {
          eta_str = '' + Math.ceil(eta_seconds) + 's';
        } else if (eta_seconds < 60*60) {
          eta_str = '' + Math.ceil(eta_seconds/60) + 'm';
        } else {
          eta_str = '' + Math.ceil(eta_seconds/(60*60)) + ' hours';
        }

        if(w === 100) $('div.status').text("Uploaded. Processing file...");
        else $('#uploading div.status').html("<div class='eta'>"+eta_str+"</div><div class='filename'>Uploading "+$('#file_upload').val()+"...</div>");
      } else if (upload.state == 'error') { 
        
        if(typeof console != "undefined" && console.log) 
          console.log(upload);

        if (upload.status == 413) {
          report_error('413', "Sorry, that video file is too big. Please try to reduce its size (by exporting or converting it) and try again.");
        } else {
          report_error('500', 'There was an error uploading your video. Please try again in a couple of minutes.');
        }
      }
    }
  });
};
