var linkConfigIndex = 1;
var apiConfigIndex = 1;

$("#btnAddLinkConfig").click(function(){
  var config = {
    configIndex: linkConfigIndex,
    name: "",
    default: "",
    required: true,
    order: linkConfigIndex
  };
  $("#link_configuration").append(getLinkConfigurationHtml(config));
  linkConfigIndex++;
});

$("#btnAddApiConfig").click(function(){
  var config = {
    configIndex: apiConfigIndex,
    name: "",
    default: "",
    required: true,
    order: apiConfigIndex
  };
  $("#api_configuration").append(getApiConfigurationHtml(config));
  apiConfigIndex++;
});

$(document).ready(function(e){
  var configuration = JSON.parse($("#resourceConfiguration").val());
  if(configuration.link_configuration) {
    $(Object.keys(configuration.link_configuration)).each(function(index,cIndex){
      var config = configuration.link_configuration[linkConfigIndex];
      config.configIndex = cIndex;
      $("#link_configuration").append(getLinkConfigurationHtml(config));
      linkConfigIndex++;
    });
  }
  if(configuration.api_configuration) {
    $(Object.keys(configuration.api_configuration)).each(function(index,cIndex){
      var config = configuration.api_configuration[apiConfigIndex];
      config.configIndex = cIndex;
      $("#api_configuration").append(getApiConfigurationHtml(config));
      apiConfigIndex++;
    });
  }  
});

function getLinkConfigurationHtml(config){
  var configIndex = config.configIndex;
  var name = config.name || "";
  var defaultValue = config.default || "";
  var required = config.required;
  var order = config.order;
  var checked = required ? "checked='checked'" : "";
  var toolOptions = "";
  for(var i = 0; i < 20; i++) {
    toolOptions += "<option "+ (order == (i+1) ? "selected='selected'" : '') +" value='"+(i+1)+"'>"+(i+1)+"</option>";
  }
  return "<div class='config"+configIndex+"'><div class='span bold'>"+configIndex+". </div>"+
    "<input class='span4' type='text' placeholder='key' name='oac_tool[integration_configuration][link_configuration]["+configIndex+"][name]' value='"+name+"'/>"+
    "<input class='span4' type='text' placeholder='default value' name='oac_tool[integration_configuration][link_configuration]["+configIndex+"][default]' value='"+defaultValue+"'/>"+
    "<select class='span4' name='oac_tool[integration_configuration][link_configuration]["+configIndex+"][order]'>"+
      toolOptions+
    "</select>"+
    "<div class='span3'><label><input type='checkbox' name='oac_tool[integration_configuration][link_configuration]["+configIndex+"][required]' "+checked+" value=true /> Required</label></div>"+
    "<div class='span2'><a data-config='config"+configIndex+"' href='javascript:void(0);' style='cursor:pointer;' class='remove' onclick='removeLinkConfig(this)'>X</a></div>"+
    "<div class='clr'></div>"+
    "<div class='divider1'></div>"+
  "</div>";
}

function getApiConfigurationHtml(config){
  var configIndex = config.configIndex;
  var name = config.name || "";
  var defaultValue = config.default || "";
  var required = config.required;
  var order = config.order;
  var checked = required ? "checked='checked'" : "";
  var toolOptions = "";
  for(var i = 0; i < 20; i++) {
    toolOptions += "<option "+ (order == (i+1) ? "selected='selected'" : '') +" value='"+(i+1)+"'>"+(i+1)+"</option>";
  }
  return "<div class='config"+configIndex+"'><div class='span bold'>"+configIndex+". </div>"+
    "<input class='span4' type='text' placeholder='key' name='oac_tool[integration_configuration][api_configuration]["+configIndex+"][name]' value='"+name+"'/>"+
    "<input class='span4' type='text' placeholder='default value' name='oac_tool[integration_configuration][api_configuration]["+configIndex+"][default]' value='"+defaultValue+"'/>"+
    "<select class='span4' name='oac_tool[integration_configuration][api_configuration]["+configIndex+"][order]'>"+
      toolOptions+
    "</select>"+
    "<div class='span3'><label><input type='checkbox' name='oac_tool[integration_configuration][api_configuration]["+configIndex+"][required]' "+checked+" value=true /> Required</label></div>"+
    "<div class='span2'><a data-config='config"+configIndex+"' href='javascript:void(0);' style='cursor:pointer;' class='remove' onclick='removeLinkConfig(this)'>X</a></div>"+
    "<div class='clr'></div>"+
    "<div class='divider1'></div>"+
  "</div>";
}

function removeLinkConfig(e){
  $("."+$(e).data("config")).remove();
}
