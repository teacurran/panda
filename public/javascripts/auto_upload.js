jQuery(function(){
  $('#file_upload').change(function(){
    $('#uploading div.status').text("Uploading "+$('#file_upload').val()+"...");
    $('#upload').submit();
  });
});
