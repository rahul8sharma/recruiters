//= require ajax

$(document).ready(function() {
  function get_states_success(response) {
    var state_name = $("input[name=state]").attr('value');
    $("#select_state").find("option").remove();
    $("#select_state").removeAttr("disabled");
    $("#select_state").append("<option value=''>Select State</option>");
    for (var i = 0; i < response.locations.length; i++) {
        var location = response.locations[i].attributes;
        if (location.name == state_name) {
            $("#select_state").append("<option value='" + location.id + "' selected>" + location.name + "</option>");
        } else {
            $("#select_state").append("<option value='" + location.id + "'>" + location.name + "</option>");
        }

    }
    $("#select_state").attr("required", "required");
  }

  function get_states_failed(response) {}

  function get_cities_success(response) {
    var city_name = $("input[name=city]").attr('value');
    $("#select_city").find("option").remove();
    $("#select_city").append("<option value=''>Select City</option>");
    $("#select_city").removeAttr("disabled");
    for (var i = 0; i < response.locations.length; i++) {
      var location = response.locations[i].attributes;
      if (location.name == city_name) {
        $("#select_city").append("<option value='" + location.id + "' selected>" + location.name + "</option>");
      } else {
        $("#select_city").append("<option value='" + location.id + "'>" + location.name + "</option>");
      }
    }
    $("#select_city").attr("required", "required");
  }

  function get_cities_failed(response) {}

  $("#select_country").on("change", function() {
    $("#select_state").attr("disabled", "disabled");
    var country = $(this).val();
    if (country != null && country != "") {
      var hash = {
        "search": {
          "parent_id": country
        }
      };
      jsonRequest("/locations/get_locations", hash, get_states_success, get_states_failed);
    }
  });

  $("#select_city").on("change", function() {
    $("#input_hq_location_id").val($(this).val());
  });

  $("#select_state").on("change", function() {
    $("#select_city").attr("disabled", "disabled");
    var state = $(this).val();
    if (state != null && state != "") {
      var hash = {
        "search": {
          "parent_id": state
        }
      };
      jsonRequest("/locations/get_locations", hash, get_cities_success, get_cities_failed);
    }
  });

  $("#select_country").trigger("change", get_states_success);
});
