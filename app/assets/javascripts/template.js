function getTemplateVariablesForCategory(category) {
  var obj = {
    joins: "template_categories",
    search: {
      "template_categories.name": category
    }
  };
  $.ajax({
    url: "/template_variables",
    data: obj,
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

function checkEmailBodyForVaribales(){
  if ($('#template_body').trumbowyg('html').match(/\<\$(.*?)\$\>/gi) == null){
    var prompt = confirm("You have not added template varibales to email body.");
    if (prompt == true){
      return true;
    }else{
      return false;
    }
  }else{
    return true;
  }
}


jQuery(document).ready(function($){ 
  var currentElement = null;

  $('#template_body').trumbowyg({
      fullscreenable: false,
      closable: false,
      btns: ['viewHTML',
    '|', 'formatting',
    '|', 'btnGrp-design',
    '|', 'link',
    '|', 'btnGrp-justify',
    '|', 'btnGrp-lists',
    '|', 'horizontalRule']
  });

  $("#template_body, #template_subject, #template_from").click(function(){
    currentElement = $(this);
  });
  
  $(document).on("click",".template_variable_link",function(){
    var template_variable = "<$"+$(this).attr("template_variable_name")+"$>";
    if (checkCurrentElement(currentElement)){
      if(currentElement.attr('id') == "template_body"){
        $('#template_body').trumbowyg('html', $('#template_body').trumbowyg('html') +" "+ template_variable);
      }else{
        currentElement.attr('value', currentElement.val()+template_variable);
      }
    }
  });
  
  $("#template_template_category_id").change(function(){
    var category = $("#template_template_category_id option:selected").text();
    getTemplateVariablesForCategory(category);
  });
  var category = $("#template_template_category_id option:selected").text();
  getTemplateVariablesForCategory(category);
  $('#new_template, #edit_template').on("submit", function(){
    return checkEmailBodyForVaribales();
  })
});

function checkCurrentElement(currentElement){
  if(currentElement.attr('id') == "template_body" || currentElement.attr('id') == "template_subject" || currentElement.attr('id') == "template_from"){
    return true;
  }else{
    return false;
  }
}