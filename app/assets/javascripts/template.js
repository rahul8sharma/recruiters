jQuery(document).ready(function($){ 
  var currentElement = null;
  $("#template_body, #template_subject, #template_from").click(function(){
    currentElement = $(this);
  });
  
  $(".template_variable_link").click(function(){
    currentElement.insertAtCaret("<$"+$(this).attr("template_variable_name")+"$>");
  });
});
