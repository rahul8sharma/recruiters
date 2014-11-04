jQuery(document).ready(function($){ 
  $(".template_variable_link").click(function(){
    $("#template_body").insertAtCaret("<$"+$(this).attr("template_variable_name")+"$>");
  });
});
