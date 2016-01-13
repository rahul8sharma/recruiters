function addCategory() {
  var categoryId = parseInt($("#template_categories").val());
  var categoryText = $("#template_categories option:selected").text();
  var added_category_ids = $("#added_category_ids").val().split(",");
  if($.inArray(categoryId,added_category_ids) == -1){
    added_category_ids.push(categoryId);
    $("#added_category_ids").val(added_category_ids.join(","));
  }
  $("#template_categories option[value='"+categoryId+"']").each(function() {
    $(this).remove();
  });
  var categoryDiv = "<div class='category' id='category"+categoryId+"'>"+
                    categoryText+"<a class='removeCategory' href='javascript:void(0);' "+
                    "data-id='"+categoryId+"'"+
                    "data-text='"+categoryText.trim()+"'>X</a>"+
                    "</div>";
  $("#selected_categories").append(categoryDiv);
}

function removeCategory(categoryId,categoryText) {
  var added_category_ids = $("#added_category_ids").val().split(",");
  added_category_ids = jQuery.grep(added_category_ids, function(value) {
    return value != categoryId;
  });
  $("#added_category_ids").val(added_category_ids.join(","));
  $("#template_categories").prepend("<option value='"+categoryId+"'>"+categoryText+"</option>");
  $("#category"+categoryId).remove();
}

$(document).on("click",".removeCategory",function(){
  removeCategory($(this).data("id"),$(this).data("text").trim());
});
