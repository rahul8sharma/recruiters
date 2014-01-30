$(document).ready(function(){
  $(".assessment_checkbox").change(function(){
    var checked = $(this).is(":checked");
    $("#enable_assessment_"+$(this).attr("assessment_id")).val(checked);
    if(checked) {
      $($(this).attr("toggle_element")).addClass("checked");
    } else {
      $($(this).attr("toggle_element")).removeClass("checked");
    }
  });
});
