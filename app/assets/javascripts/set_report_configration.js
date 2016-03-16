//= require jstree.min
var $htmlTree, $pdfTree = null;
var defaultSelectedObject = { 
  html: { sections: [] },
  pdf: { sections: [] }  
};
var reportType = $('#report_type').val();
var company_id = $('#input_company_id').val();
  

function loadConfig(assessment_Type, reportType) {
  var reportType = reportType;
  var assessmentType = assessment_Type;
  var viewMode = viewMode;
  var uri = "report_type="+reportType+"&assessment_type="+assessmentType+"&company_id="+$("#input_company_id").val();
  $.ajax({ 
    type: "GET",
    url: "/report_configurations/load_configuration/?"+uri,
    dataType: 'json',
    success: function(response_data) {
      if(response_data.error) {
        alert(response_data.error);
      } else {
        destroyJSTrees();
        createJSTrees();
        var config = JSON.parse(response_data.config);
        var input_json = {};
        if($('#input_assessment_id').val()){
          input_json = $('#input_config').val() ? JSON.parse($('#input_config').val()) : {}
        } else {
          input_json = {};
        }
        var data = jQuery.isEmptyObject(input_json) ? JSON.parse(response_data.selected) : input_json;
        data.html = data.html || { sections: [] };
        data.pdf = data.pdf || { sections: [] };
        data.html.sections = data.html.sections || [];
        data.pdf.sections = data.pdf.sections || [];
        var selectedHtmlSectionIds = $.map(data.html.sections, function(section){ return section.id; });
        var selectedPdfSectionIds = $.map(data.pdf.sections, function(section){ return section.id; });
        if(selectedHtmlSectionIds.length > 0) {
          config.html.sections.sort(function(a,b){
            if(selectedHtmlSectionIds.indexOf(a.id) == -1) {
              return 1;
            } else if(selectedHtmlSectionIds.indexOf(b.id) == -1) {
              return -1;
            } else {
              return selectedHtmlSectionIds.indexOf(a.id) - selectedHtmlSectionIds.indexOf(b.id);
            }  
          });
        }
        if(selectedPdfSectionIds.length > 0) {
          config.pdf.sections.sort(function(a,b){
            if(selectedPdfSectionIds.indexOf(a.id) == -1) {
              return 1;
            } else if(selectedPdfSectionIds.indexOf(b.id) == -1) {
              return -1;
            } else {
              return selectedPdfSectionIds.indexOf(a.id) - selectedPdfSectionIds.indexOf(b.id);
            }
          });
        }
        
        $htmlTree.settings.core.data = config.html.sections; 
        $htmlTree.selected = data.html.sections;
        $htmlTree.refresh();
        
        $pdfTree.settings.core.data = config.pdf.sections; 
        $pdfTree.selected = data.pdf.sections;          
        $pdfTree.refresh();
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

function createNode($jsTree, id){
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
  hash["sections"] = configuration
  return hash;
}

function sortChildren(arr, children){
  arr = arr.sort(function(a, b){
    return (children.indexOf(a.id) - children.indexOf(b.id));
  });
  return arr;
}

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

function deselect_related_nodes(data){
  if(data.node.original.links){
    for(var i = 0; i < data.node.original.links.html.length; i++) {
      var linkedNode = data.node.original.links.html[i];
      $htmlTree.deselect_node(linkedNode);
    }
    for(var i = 0; i < data.node.original.links.pdf.length; i++) {
      var linkedNode = data.node.original.links.pdf[i];
      $pdfTree.deselect_node(linkedNode);
    }
  }
  if(data.node.children_d.length > 0){
    for(var i = 0; i < data.node.children_d.length; i++){
      var childrenNode = data.node.children_d[i];
      $htmlTree.deselect_node(childrenNode);
    }
  }
  if(data.node.parents.length > 0){
    for(var i = 0; i < data.node.parents.length; i++){
      var parentNode = $htmlTree.get_node(data.node.parents[i]);
      if(!$htmlTree.is_selected(parentNode)){
        if(parentNode.original && parentNode.original.links && parentNode.original.links.pdf.length > 0){
          for(var i = 0; i < parentNode.original.links.pdf.length; i++) {
            var linkedNode = parentNode.original.links.pdf[i];
            $pdfTree.deselect_node(linkedNode);
          }  
        }
      }
    }
  }
}

function select_related_nodes(data){
  if(data.node.original.links){
    for(var i = 0; i < data.node.original.links.html.length; i++) {
      var linkedNode = data.node.original.links.html[i];
      $htmlTree.select_node(linkedNode);
    }
    for(var i = 0; i < data.node.original.links.pdf.length; i++) {
      var linkedNode = data.node.original.links.pdf[i];
      $pdfTree.select_node(linkedNode);
    }
  }
  if(data.node.children_d.length > 0){
    for(var i = 0; i < data.node.children_d.length; i++){
      var childrenNode = data.node.children_d[i];
      $htmlTree.select_node(childrenNode);
    }
  }
  if(data.node.parents.length > 0){
    for(var i = 0; i < data.node.parents.length; i++){
      var parentNode = $htmlTree.get_node(data.node.parents[i]);
      if(parentNode.original && parentNode.original.links && parentNode.original.links.pdf.length > 0){
        for(var i = 0; i < parentNode.original.links.pdf.length; i++) {
          var linkedNode = parentNode.original.links.pdf[i];
          $pdfTree.select_node(linkedNode);
        }  
      }
    }
  }
}

function createJSTree(container){
  $(container).on('deselect_node.jstree', function (e, data) {
    deselect_related_nodes(data);
  }).on('select_node.jstree', function (e, data) {
    select_related_nodes(data);
  }).on('changed.jstree', function (e, data) {
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
    updateInput();
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

function generatePreview(assessmentType, viewMode, $jsTree, candidate_type, custom_message){  
  var uri = "view_mode="+viewMode;
  uri += "&assessment_type="+assessmentType;
  uri += "&report_type="+reportType;
  uri += "&company_id="+company_id;
  uri += "&candidate_type="+candidate_type;
  uri += "&custom_message="+custom_message;
  
  var url = "/report_configurations/report_preview_"+reportType+"/?"+uri;
  var configuration = updateInput();
  
  var form_data = {
    "config": JSON.stringify(configuration),
    "authenticity_token": $('input[name="authenticity_token"]').val()
  }
  $.ajax({ 
    method: "POST",
    url: url,
    data: form_data,
    dataType: 'json',
    success: function(data)
    {   
      enablePreviewButtons();
      $("#iframe1").show();
      document.getElementById('iframe1').contentWindow.document.body.innerHTML = '';  
      document.getElementById('iframe1').contentWindow.document.write(data.content);
      $('html, body').animate({
        scrollTop: $("#iframe1").offset().top - 100
      }, 500);
    },error: function(error) { 
      enablePreviewButtons();
      document.getElementById('iframe1').contentWindow.document.write("Error while loading the preview.");
    }
  });
}

function enablePreviewButtons(){
  $("#generate_html_preview").removeAttr("disabled");
  $("#generate_pdf_preview").removeAttr("disabled");
  $("#generate_html_preview").html("Generate HTML Preview");
  $("#generate_pdf_preview").html("Generate PDF Preview");
}

function loadPreview($btn, $tree, candidate_type, custom_message){
  $btn.html("Please wait...");
  $btn.attr("disabled", true);
  document.getElementById('iframe1').contentWindow.document.body.innerHTML = ''; 
  updateInput();
  generatePreview($('#set_assessment_type').val(), $btn.attr("type"), $tree, candidate_type, custom_message);
}

function destroyJSTrees(){
  $htmlTree.destroy();
  $pdfTree.destroy();
}

function createJSTrees(){
  $htmlTree = createJSTree("#html_configuration");
  $htmlTree.treeType = "html";
  $pdfTree = createJSTree("#pdf_configuration");
  $pdfTree.treeType = "pdf";
}

$(document).ready(function(){
  reportType = $('#report_type').val();
  company_id = $('#input_company_id').val();
  

  $("#set_assessment_type").change(function(){    
    loadConfig($('#set_assessment_type').val(), reportType);
  });
  
  $("#check_use_competencies").change(function(){
    if($(this).is(":checked")){
      $("#set_assessment_type").val("competency");
      loadConfig($('#set_assessment_type').val(), reportType);
    } else {
      $("#set_assessment_type").val("fit");
      loadConfig($('#set_assessment_type').val(), reportType);
    }
  });
  
  $('#generate_html_preview').on('click', function(e){
    e.preventDefault();
    var candidate_type = $('#set_candidate_type').length == 1 ? $('#set_candidate_type').val() : "employed";
    var custom_message = $('#exercise_cover_letter').length == 1 ?$('#exercise_cover_letter').val() : "";
    if($('#set_assessment_type').val() !== "") {
      loadPreview($(this), $htmlTree, candidate_type,custom_message);
    } else {
      alert("Please select assessment type!");
    }
  });

  $('#generate_pdf_preview').on('click', function(e){
    e.preventDefault();
    var candidate_type = $('#set_candidate_type').length == 1 ? $('#set_candidate_type').val() : "employed";
    var custom_message = $('#exercise_cover_letter').length ==1 ?$('#exercise_cover_letter').val() : "";
    if($('#set_assessment_type').val() !== "") {
      loadPreview($(this), $pdfTree, candidate_type,custom_message);
    } else {
      alert("Please select assessment type!");
    }  
  });


  $('#assessment_form').submit(function(e) {
    updateInput();
    return true;
  });
  createJSTrees();  
  if($('#set_assessment_type').val() !== "") {
    loadConfig($('#set_assessment_type').val(), reportType);
  }
});
