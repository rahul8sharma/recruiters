//= require jstree.min
// var selected = [];
var $htmlTree, $pdfTree = null;
var defaultSelectedObject = { 
  html: { sections: [] },
  pdf: { sections: [] }  
};

function loadConfig(assessment_Type, $jsTree, viewMode) {
  var reportType = 'mrf';
  var assessmentType = assessment_Type;
  var viewMode = viewMode;
  var uri = "report_type="+reportType+"&assessment_type="+assessmentType+"&view_mode="+viewMode;
  $.ajax({ 
    type: "GET",
    url: "/report_configurations/load_configuration?"+uri,
    dataType: 'json',
    success: function(data) {
      var config = JSON.parse(data.config);
      var data = $('#input_config').val() ? JSON.parse($('#input_config').val()) : defaultSelectedObject;
      $jsTree.selected = $jsTree.treeType == "html" ? data.html.sections : data.pdf.sections;
      if(data.error) {
        alert(data.error);
      } else {
        $jsTree.settings.core.data = config; 
        $jsTree.refresh();
      }
    },
    error: function(error){
      alert(error.statusText);
    }
  });
}

function setSelected(obj, $jsTree){
  if(obj.children == null || obj.children.length == 0) {
    $jsTree.select_node(obj.id);
    return obj.id;
  } else {
    for(var i = 0; i < obj.children.length; i++) {
      var o = obj.children[i];
      setSelected(o, $jsTree);
    }
  }
}

function createNode(id, $jsTree){
  var obj = $jsTree.get_node(id).original;
  obj.children = [];
  obj.state = { selected: true };
  return obj;
}

function getConfiguration($jsTree){
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
      objects[parent.id] = createNode(parent.id, $jsTree);;      
    } 
    objects[obj.id] = createNode(obj.id, $jsTree);;
  }
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
  $("#set_assessment_type").change(function(){    
    loadConfig($('#set_assessment_type').val(), $htmlTree, 'html');
    loadConfig($('#set_assessment_type').val(), $pdfTree, 'pdf');
  });
  
  $('#generate_html_preview').on('click', function(){
    updateInput();
    generatePreview($('#set_assessment_type').val(), 'html', $('#ReportPreview'), $htmlTree);
  });


  $('#generate_pdf_preview').on('click', function(){
    updateInput();
    generatePreview($('#set_assessment_type').val(), 'pdf', $('#ReportPreview'), $pdfTree);
  });


  $('#assessment_form').submit(function(e) {
    updateInput();
    return true;
  });
    
  $htmlTree = createJSTree("#html_configuration");
  $htmlTree.treeType = "html";
  $pdfTree = createJSTree("#pdf_configuration");
  $pdfTree.treeType = "pdf";

  loadConfig($('#set_assessment_type').val(), $htmlTree, 'html');
  loadConfig($('#set_assessment_type').val(), $pdfTree, 'pdf');
});

function updateInput(){
  var html_configuration = getConfiguration($htmlTree);
  var pdf_configuration = getConfiguration($pdfTree);
  var configuration = {
    html: html_configuration,
    pdf: pdf_configuration
  };
  $("#input_config").val(JSON.stringify(configuration));   
  return configuration;
}

function createJSTree(container){
  $(container).on('changed.jstree', function (e, data) {
  }).on('refresh.jstree', function (e, data) {
    data.instance.selected = data.instance.selected || [];
    var selected = data.instance.selected;
    for(var i = 0; i < selected.length; i++) {
      var obj = selected[i];
      if(obj.children == null || obj.children.length == 0) {
        data.instance.select_node(obj.id);
      } else {
        setSelected(obj, data.instance);
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
  return $(container).jstree(true);

}

function generatePreview(assessmentType, viewMode, container, $jsTree){
  container.html("Loading...");
  var uri = "view_mode="+viewMode+"&assessment_type="+assessmentType;
  var configuration = updateInput();
  var form_data = {
    "config": JSON.stringify(configuration),
    "authenticity_token": $('input[name="authenticity_token"]').val()
  }
  $.ajax({ 
      type: "POST",
      url: "/companies/2/360/report_preview?"+uri,
      data: form_data,
      dataType: 'json',
      success: function(data)
      {   
        container.html(data.content);
      },error: function(data) { 
        container.html('');
      }
    });
}

// loadConfig($('#set_assessment_type').val());
