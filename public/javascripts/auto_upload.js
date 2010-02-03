jQuery(function(){
  $('#file_upload').change(function(){
    $('#uploading div.filename').text("Uploading "+$('#file_upload').val()+"...");
    $('#upload').submit();
  });
});
