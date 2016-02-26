$(function() { 
  var combinationChanged = false;
  $("#select_industry").change(function(){
    combinationChanged = true;
  });
  $("#select_functional_area").change(function(){
    combinationChanged = true;
  });
  $("#select_job_experience").change(function(){
    combinationChanged = true;
  }); 
  
  $("#assessment_form").on("submit", function(){
    if(combinationChanged) {
      var selectedIndustry = $("#select_industry option:selected").text();
      var selectedFa = $("#select_functional_area option:selected").text();
      var selectedExp = $("#select_job_experience option:selected").text();
      var prompt = confirm("Norms for this combination (Industry:"+selectedIndustry+", Function: "+
        selectedFa +" and Experience: "+ selectedExp +") will be picked. Are You Sure?");
      return prompt;  
    }
    return true;
  });
});
