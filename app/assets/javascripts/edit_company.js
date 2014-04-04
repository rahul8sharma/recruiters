function jsonRequest(url,dataHash,success_callback_function,failure_callback_function){
	$.ajax(url, {
			type: 'GET',
			data: dataHash,
			dataType: 'json',
			success: function(response) { 
				success_callback_function(response);
			},
			error: function(response) { 
				failure_callback_function(response);
			}
	});	
}

$(document).ready(function(){
  function get_states_success(response) {
    $("#select_state").find("option").remove();
    $("#select_state").removeAttr("disabled");
    $("#select_state").append("<option>Select State</option>");
    for(var i = 0; i < response.locations.length; i++) {
      var location = response.locations[i].attributes;
      $("#select_state").append("<option value='"+location.id+"'>"+location.name+"</option>");
    }
  }
  
  function get_states_failed(response) {
  }
  
  function get_cities_success(response) {
    $("#select_city").find("option").remove();
    $("#select_city").append("<option>Select City</option>");
    $("#select_city").removeAttr("disabled");
    for(var i = 0; i < response.locations.length; i++) {
      var location = response.locations[i].attributes;
      $("#select_city").append("<option value='"+location.id+"'>"+location.name+"</option>");
    }
  }
  
  function get_cities_failed(response) {
  }
  
  $("#select_country").on("change",function(){
    $("#select_state").attr("disabled","disabled");
    var hash = { "search": { "parent_id": $(this).val() } };
    jsonRequest("/locations/get_locations",hash, get_states_success, get_states_failed);
  });
  
  $("#select_city").on("change",function(){  
    $("#input_hq_location_id").val($(this).val());
  });
  
  $("#select_state").on("change",function(){
    $("#select_city").attr("disabled","disabled");
    var hash = { "search": { "parent_id": $(this).val() } };
    jsonRequest("/locations/get_locations",hash, get_cities_success, get_cities_failed);
  });
  
  $("#select_country").trigger("change");
});
