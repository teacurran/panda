jQuery(function(){
  $('#file_upload').change(function(){
    var value = $('#file_upload').val();
    setTimeout(function(){
      if($('#file_upload').val() == value) $('#upload').submit();
    }, 6500);
  });
});
