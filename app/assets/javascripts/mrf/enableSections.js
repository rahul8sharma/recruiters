//= require jstree.min
var selected = [];
var $jstree = null;
function loadConfig(viewType, assessment_Type) {
  var reportType = 'mrf';
  var assessmentType = assessment_Type;
  var viewMode = viewType;
  var uri = "report_type="+reportType+"&assessment_type="+assessmentType+"&view_mode="+viewMode;
  $.ajax({ 
    type: "GET",
    url: "/report_configurations/load_configuration?"+uri,
    dataType: 'json',
    success: function(data) {
      var config = JSON.parse(data.config);
      selected = JSON.parse(data.selected);
      if(data.error) {
        alert(data.error);
      } else {
        $jstree.settings.core.data = config; 
        $jstree.refresh();
      }
    },
    error: function(error){
      alert(error.statusText);
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

function createNode(id){
  var obj = $jstree.get_node(id).original;
  obj.children = [];
  obj.state = { selected: true };
  return obj;
}

function getConfiguration(){
  var hash = {}
  var configuration = [];
  var objects = {};
  var root = null;
  var selected = $jstree.get_checked('full');
  //console.log(selected);
  for(var i = 0; i < selected.length; i++) {
    var obj = selected[i];
    var parent = $jstree.get_node(obj.parent);
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
      var parent_node = $jstree.get_node(obj.parent);
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
  var root = $jstree.get_node("#");
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
  $("#set_view_mode").change(function(){    
    if($('#set_assessment_type').val() != ""){
      loadConfig($('#set_view_mode').val(), $('#set_assessment_type').val());
    }else{
      alert('Set Assessment Type');
    }

  });

  $("#set_assessment_type").change(function(){    
    if($('#set_view_mode').val() != ""){
      loadConfig($('#set_view_mode').val(), $('#set_assessment_type').val());
    }else{
      alert('Set View Mode');
    }    

  });
  
  $('#generate_preview').on('click', function(){
    generatePreview();
  });

  $('#assessment_form').submit(function(e) {
    //e.preventDefault();
    var configuration = getConfiguration();
    $("#input_config").val(JSON.stringify(configuration));
    return true;
  });
  
  $('#html_configuration').on('changed.jstree', function (e, data) {
  }).on('refresh.jstree', function (e, data) {
    for(var i = 0; i < selected.length; i++) {
      var obj = selected[i];
      if(obj.children == null || obj.children.length == 0) {
        $jstree.select_node(obj.id);
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
  $jstree = $('#html_configuration').jstree(true);
});

function generatePreview(){
  $("#ReportPreview").html("Loading...");
  var configuration = getConfiguration(); 
  var form_data = {
    "config": JSON.stringify(configuration),
    "authenticity_token": $('input[name="authenticity_token"]').val()
  }
  $.ajax({ 
      type: "POST",
      url: "/companies/2/360/report_preview",
      data: form_data,
      dataType: 'json',
      success: function(data)
      {   
        $("#ReportPreview").html(data.content);
      },error: function(data) { 
        $("#ReportPreview").html('');
      }
    });
}

// loadConfig($('#set_view_mode').val(), $('#set_assessment_type').val());
