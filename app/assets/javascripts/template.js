function getTemplateVariablesForCategory(category) {
  $.ajax({
    url: "/template_variables",
    data: { joins: "template_categories", search: { "template_categories.name": category } },
    success: function(data){
      $("#template_variables").html("");
      $(data).each(function(index,object){
        var template_variable = object.attributes;
        var link = "";
        link += "<li title='"+template_variable.value+"'>"+template_variable.id+" "+
            "<a href='javascript:void(0);' class='template_variable_link' template_variable_name='"+template_variable.id+"'>"+
              " "+template_variable.name+
            "</a>"
        $("#template_variables").append(link);
      });
    },
    dataType: "json"
  });
}

jQuery(document).ready(function($){ 
  var currentElement = null;
  $("#template_body, #template_subject, #template_from").click(function(){
    currentElement = $(this);
  });
  
  $(document).on("click",".template_variable_link",function(){
    currentElement.insertAtCaret("<$"+$(this).attr("template_variable_name")+"$>");
  });
  
  $("#template_category").change(function(){
    var category = $(this).val();
    getTemplateVariablesForCategory(category);
  });
  var category = $("#template_category").val();
  getTemplateVariablesForCategory(category);
});
