//= require jstree.min

var $jstree = null;
$(document).ready(function(){
  var data = $(".config").data("config");
  $('#configuration').jstree({
    "core" : {
      'data' : data
    }
  });
});
