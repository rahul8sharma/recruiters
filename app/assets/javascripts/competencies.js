jQuery(function($){
  $("#check_all_global").change(function(){
    $(".global_competency").attr("checked",$(this).is(":checked"));
  });
  
  $("#check_all_local").change(function(){
    $(".local_competency").attr("checked",$(this).is(":checked"));
  });
});
