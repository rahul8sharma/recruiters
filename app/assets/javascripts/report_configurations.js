//= require jstree.min
var selected = [];
var $pdfTree = null;
var $htmlTree = null;
function loadConfig() {
  var reportType = $('#select_report_type :selected').text();
  var assessmentType = $('#select_assessment_type :selected').text();
  var uri = "report_type="+reportType+"&assessment_type="+assessmentType;
  if($("#report_configuration_id").length > 0) {
    uri = uri + "&id="+$("#report_configuration_id").val();
  }
  $.ajax({ 
    type: "GET",
    url: "/report_configurations/load_configuration?"+uri,
    dataType: 'json',
    success: function(data) {
      var config = JSON.parse(data.config);
      var selected = JSON.parse(data.selected);
      $htmlTree.selected = selected.html.sections
      $pdfTree.selected = selected.pdf.sections;
      if(data.error) {
        alert(data.error);
      } else {
        $htmlTree.settings.core.data = config.html.sections;
        $pdfTree.settings.core.data = config.pdf.sections;
        $htmlTree.refresh();
        $pdfTree.refresh();
      }
    },
    error: function(error){
      alert(error.statusText);
    }
  });
}

function setSelected($jsTree, obj){
  if(obj.children == null || obj.children.length == 0) {
    $jsTree.select_node(obj.id);
    return obj.id;
  } else {
    for(var i = 0; i < obj.children.length; i++) {
      var o = obj.children[i];
      setSelected($jsTree, o);
    }
  }
}

function createNode($jsTree, id){
  var obj = $jsTree.get_node(id).original;
  obj.children = [];
  obj.state = { selected: true };
  return obj;
}

function getConfigurationForTree($jsTree){
  var hash = {}
  var configuration = [];
  var objects = {};
  var root = null;
  var selected = $jsTree.get_checked('full');
  //console.log(selected);
  for(var i = 0; i < selected.length; i++) {
    var obj = selected[i];
    var parent = $jsTree.get_node(obj.parent);
    if(parent && parent.parent == "#") {
      objects[parent.id] = createNode($jsTree, parent.id);;      
    } 
    objects[obj.id] = createNode($jsTree, obj.id);;
  }
  //var selected = $jsTree.selected;
  for(var i = 0; i < selected.length; i++) {
    var obj = selected[i];
    if(obj.parent == "#") {
      root = objects[obj.id];
    } else {
      var parent_node = $jsTree.get_node(obj.parent);
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
  var root = $jsTree.get_node("#");
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
  $htmlTree = createJSTree("#html_configuration", "html");
  $pdfTree = createJSTree("#pdf_configuration", "pdf");

  $(".config").change(function(){
    loadConfig();
  });
  
  $('#config_form').submit(function(e) {
    //e.preventDefault();
    var configuration = getConfiguration();
    $("#input_config").val(JSON.stringify(configuration));
    return true;
  });
  loadConfig();
});

function getConfiguration(){
  var html_configuration = getConfigurationForTree($htmlTree);
  var pdf_configuration = getConfigurationForTree($pdfTree);
  var configuration = {
    html: html_configuration,
    pdf: pdf_configuration
  }
  return configuration;
}

function createJSTree(container, viewMode){
  $(container).on('changed.jstree', function (e, data) {
  }).on('refresh.jstree', function (e, data) {
    var selected = data.instance.selected;
    for(var i = 0; i < selected.length; i++) {
      var obj = selected[i];
      if(obj.children == null || obj.children.length == 0) {
        data.instance.select_node(obj.id);
      } else {
        setSelected(data.instance, obj);
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
  var tree = $(container).jstree(true);
  tree.viewMode = viewMode;
  return tree;
}

