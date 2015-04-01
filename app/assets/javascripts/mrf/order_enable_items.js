$(document).ready(function(){
  $("#checkAllOther").on("change", function(){
    $(".other").prop("checked", $(this).is(":checked"));
  });
  
  $("#checkAllSelf").on("change", function(){
    $(".self").prop("checked", $(this).is(":checked"));
  });
});
