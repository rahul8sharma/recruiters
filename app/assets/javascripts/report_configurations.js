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

function deselect_related_nodes(data){
  if(data.node.original.links){
    for(var linkedNodeIndex = 0; linkedNodeIndex < data.node.original.links.html.length; linkedNodeIndex++) {
      var linkedNode = data.node.original.links.html[linkedNodeIndex];
      $htmlTree.deselect_node(linkedNode);
    }
    for(var linkedNodeIndex = 0; linkedNodeIndex < data.node.original.links.pdf.length; linkedNodeIndex++) {
      var linkedNode = data.node.original.links.pdf[linkedNodeIndex];
      $pdfTree.deselect_node(linkedNode);
    }
  }
  if(data.node.children_d.length > 0){
    for(var childIndex = 0; childIndex < data.node.children_d.length; childIndex++){
      var childrenNode = data.node.children_d[childIndex];
      $htmlTree.deselect_node(childrenNode);
    }
  }
  if(data.node.parents.length > 0){
    for(var parentIndex = 0; parentIndex < data.node.parents.length; parentIndex++){
      var parentNode = $htmlTree.get_node(data.node.parents[parentIndex]);
      if(!$htmlTree.is_selected(parentNode)){
        if(parentNode.original && parentNode.original.links && parentNode.original.links.pdf.length > 0){
          for(var linkedNodeIndex = 0; linkedNodeIndex < parentNode.original.links.pdf.length; linkedNodeIndex++) {
            var linkedNode = parentNode.original.links.pdf[linkedNodeIndex];
            $pdfTree.deselect_node(linkedNode);
          }  
        }
      }
    }
  }
}

function select_related_nodes(data){
  if(data.node.original.links){
    for(var linkedNodeIndex = 0; linkedNodeIndex < data.node.original.links.html.length; linkedNodeIndex++) {
      var linkedNode = data.node.original.links.html[linkedNodeIndex];
      $htmlTree.select_node(linkedNode);
    }
    for(var linkedNodeIndex = 0; linkedNodeIndex < data.node.original.links.pdf.length; linkedNodeIndex++) {
      var linkedNode = data.node.original.links.pdf[linkedNodeIndex];
      $pdfTree.select_node(linkedNode);
    }
  }
  if(data.node.children_d.length > 0){
    for(var childIndex = 0; childIndex < data.node.children_d.length; childIndex++){
      var childrenNode = data.node.children_d[childIndex];
      $htmlTree.select_node(childrenNode);
    }
  }
  if(data.node.parents.length > 0){
    for(var parentIndex = 0; parentIndex < data.node.parents.length; parentIndex++){
      var parentNode = $htmlTree.get_node(data.node.parents[parentIndex]);
      if(parentNode.original && parentNode.original.links && parentNode.original.links.pdf.length > 0){
        for(var linkedNodeIndex = 0; linkedNodeIndex < parentNode.original.links.pdf.length; linkedNodeIndex++) {
          var linkedNode = parentNode.original.links.pdf[linkedNodeIndex];
          $pdfTree.select_node(linkedNode);
        }  
      }
    }
  }
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
    objects[obj.id] = createNode($jsTree, obj.id);;
    for(var j = 0;  j < obj.parents.length; j++) {
      var parent = $jsTree.get_node(obj.parents[j]);
      if($.inArray(parent, selected) == -1 && parent.id !== "#") {
        objects[parent.id] = createNode($jsTree, parent.id);;      
        selected.push(parent);
      }
    }
  }
  //console.log(selected);
  //var selected = $jsTree.selected;
  for(var i = 0; i < selected.length; i++) {
    var obj = selected[i];
    if(obj.parent == "#") {
      root = objects[obj.id];
    } else {
      var parent_node = $jsTree.get_node(obj.parent);
      var parent = objects[obj.parent];
      parent.children.push(objects[obj.id]);
      parent.children = sortChildren(parent.children, parent_node.children)
    }
    if(root != null && $.inArray(root, configuration) == -1) {
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
  $(container).on('deselect_node.jstree', function (e, data) {
    deselect_related_nodes(data);
  }).on('select_node.jstree', function (e, data) {
    select_related_nodes(data);
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

