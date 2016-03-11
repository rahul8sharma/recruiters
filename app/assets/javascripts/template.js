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
  if ($('#template_html_editor').html().match(/\&lt;\$(.*?)\$\&gt;|\<\$(.*?)\$\>/gi) == null){
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
  var editor = $('#template_html_editor');
  
  editor.trumbowyg({
      fullscreenable: false,
      closable: false,
      semantic: true,
      resetCss: true,
      removeformatPasted: true,
      semantic: true,
      btns: ['viewHTML',
    '|', 'formatting',
    '|', 'btnGrp-design',
    '|', 'link',
    '|', 'btnGrp-justify',
    '|', 'btnGrp-lists',
    '|', 'horizontalRule',
    '|', 'removeformat']
  });

  getTemplateBodyValue($('input[name="template[body]"').val(), editor);

  $("#template_html_editor, #template_subject, #template_from").click(function(){
    currentElement = $(this);
  });
  
  $(document).on("click",".template_variable_link",function(){
    var template_variable = "<$"+$(this).attr("template_variable_name")+"$>";
    if(currentElement.attr('id') == "template_html_editor"){
        var link = $(['<span>', template_variable, '</span>'].join(''));
        editor.trumbowyg('saveSelection');
        editor.trumbowyg('getSelection').deleteContents();
        editor.trumbowyg('getSelection').insertNode(link.get(0));
        editor.trumbowyg('restoreSelection');
        editor.trumbowyg('saveSelection');
        setTemplateBodyValue($('#template_html_editor').html());
    }else{
      currentElement.insertAtCaret(template_variable);
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

function setTemplateBodyValue(value){
  $('input[name="template[body]"').attr('value', value);
}
function getTemplateBodyValue(value, editor){
  editor.trumbowyg('html', value);
}