function addField(selector, association, content){
  $(selector).append(content);
  var randomId = Math.floor(Math.random(1000)*10000);
  $("#new_fields_").find("input, select, textarea").each(function(){
    var name = $(this).attr("name");
    if(name !== undefined) {
      var newName = name.replace("new_defined_fields",randomId);
      $(this).attr("name",newName);
    }
    var id = $(this).attr("id");
    if(id !== undefined) {
      var newId = id.replace("new_defined_fields",randomId);
      $(this).attr("id",newId);
    }
  });
  $("#new_fields_").attr("id","new_fields_"+randomId);
}
