//= require jstree.min

var $jstree = null;
var selected = [];
function loadConfig() {
  var reportType = $('#select_report_type :selected').text();
  var assessmentType = $('#select_assessment_type :selected').text();
  var viewMode = $('#select_view_mode :selected').text();
  var uri = "report_type="+reportType+"&assessment_type="+assessmentType+"&view_mode="+viewMode;
  if($("#report_configuration_id").length > 0) {
    uri = uri + "&id="+$("#report_configuration_id").val();
  }
  $.ajax({ 
    type: "GET",
    url: "/report_configurations/load_configuration?"+uri,
    dataType: 'json',
    success: function(data) {
      var config = JSON.parse(data.config);
      selected = JSON.parse(data.selected);
      $('#configuration').jstree(true).settings.core.data = config;
      $('#configuration').jstree(true).refresh();
    },
    error: function(error){
      console.log(error);
    }
  });
}

function setSelected(obj){
  if(obj.children == null || obj.children.length == 0) {
    $jstree.select_node(obj.id);
    return obj.id;
  } else {
    for(var i = 0; i < obj.children.length; i++) {
      var o = obj.children[i];
      setSelected(o);
    }
  }
}

function getConfiguration(){
  var hash = {}
  var configuration = [];
  var objects = {};
  var root = null;
  var selected = $jstree.get_checked('full');
  for(var i = 0; i < selected.length; i++) {
    var obj = selected[i];
    var parent = $jstree.get_node(obj.parent);
    if(parent && parent.parent == "#") {
      root_obj = $jstree.get_node(parent.id).original;
      root_obj.children = [];
      root_obj.state = { selected: true };
      objects[root_obj.id] = root_obj;      
    }
    var final_obj = obj.original;
    final_obj.children = [];
    final_obj.state = { selected: true };
    objects[final_obj.id] = final_obj;
  }
  for(var i = 0; i < selected.length; i++) {
    var obj = selected[i];
    if(obj.parent == "#") {
    } else {
      var parent = $jstree.get_node(obj.parent);
      if(parent && parent.parent == "#") {
        root = objects[parent.id];
      }
      var parent = objects[obj.parent];
      var original = obj.original;
      original.state = { selected: true };
      parent.children.push(original);
    }
  }
  configuration.push(root);
  hash["sections"] = configuration
  return hash;
}

$(document).ready(function(){
  $(".config").change(function(){
    loadConfig();
  });
  
  $('#config_form').submit(function(e) {
    //e.preventDefault();
    var configuration = getConfiguration();
    $("#input_config").val(JSON.stringify(configuration));
    return true;
  });
  
  $('#configuration').on('changed.jstree', function (e, data) {
  }).on('refresh.jstree', function (e, data) {
    for(var i = 0; i < selected.length; i++) {
      var obj = selected[i];
      if(obj.children == null || obj.children.length == 0) {
        $jstree.select_node(obj.id);
        return obj.id;
      } else {
        setSelected(obj);
      }
    }
  }).jstree({
    "checkbox" : {
      "keep_selected_style" : true
    },
    "plugins" : [ "checkbox" ],
    "core" : {
      "full": true,
      "multiple" : true,
      "animation" : 0,
      'data' : []
    }
  });
  
  $jstree = $('#configuration').jstree();
});
loadConfig();
