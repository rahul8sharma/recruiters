//= require jstree.min

var $jstree = null;
$(document).ready(function(){
  var data = $(".config").data("config");
  $('#html_configuration').jstree({
    "core" : {
      'data' : data.html.sections
    }
  });
  $('#pdf_configuration').jstree({
    "core" : {
      'data' : data.pdf.sections
    }
  });
});
