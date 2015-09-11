//= require jstree.min
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
    $('#configuration').jstree(true).select_node(obj.id);
    return obj.id;
  } else {
    for(var i = 0; i < obj.children.length; i++) {
      var o = obj.children[i];
      setSelected(o);
    }
  }
}

function createNode(id){
  var obj = $('#configuration').jstree(true).get_node(id).original;
  obj.children = [];
  obj.state = { selected: true };
  return obj;
}

function getConfiguration(){
  var hash = {}
  var configuration = [];
  var objects = {};
  var root = null;
  var selected = $('#configuration').jstree(true).get_checked('full');
  //console.log(selected);
  for(var i = 0; i < selected.length; i++) {
    var obj = selected[i];
    var parent = $('#configuration').jstree(true).get_node(obj.parent);
    if(parent && parent.parent == "#") {
      objects[parent.id] = createNode(parent.id);;      
    } 
    objects[obj.id] = createNode(obj.id);;
  }
  for(var i = 0; i < selected.length; i++) {
    var obj = selected[i];
    if(obj.parent == "#") {
      root = objects[obj.id];
    } else {
      var parent_node = $('#configuration').jstree(true).get_node(obj.parent);
      if(parent_node && parent_node.parent == "#") {
        root = objects[parent_node.id];
      } 
      var parent = objects[obj.parent];
      parent.children.push(objects[obj.id]);
      if(parent_node) {
        parent.children = sortChildren(parent.children, parent_node.children)
      }
    }
    if($.inArray(root, configuration) == -1) {
      configuration.push(root);
    }
  }
  var root = $('#configuration').jstree(true).get_node("#");
  configuration = sortChildren(configuration, root.children);
  //console.log(configuration);
  hash["sections"] = configuration
  return hash;
}

function sortChildren(arr, children){
  arr = arr.sort(function(a, b){
    return (children.indexOf(a.id) - children.indexOf(b.id));
  });
  return arr;
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
        $('#configuration').jstree(true).select_node(obj.id);
      } else {
        setSelected(obj);
      }
    }
  }).jstree({
    "checkbox" : {
      "keep_selected_style": false,
      "whole_node": false
    },
    "dnd": {
      "drag_selection": false
    },
    "plugins" : [ "checkbox", "dnd" ],
    "core" : {
      "check_callback": function(operation, node, node_parent, node_position, more) {
        if (operation === "move_node") {
          return node.parent === node_parent.id ;
        }
        return true;  //allow all other operations
      },
      "full": true,
      "multiple" : true,
      "animation" : 0,
      'data' : []
    }
  });
});
loadConfig();
