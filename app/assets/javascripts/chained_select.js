// Populate select box with new options
function populate_select(select_box, data, data_source, generate_option, prompt) {
  select_box.attr('disabled', 'disabled');
  prompt = prompt || "Please select";
  select_box.empty().append('<option value="">' + prompt + '</option>');

  data.sort(function(a, b) {
    if(a[data_source].name < b [data_source].name) {
      return -1;
    }
    else if(a[data_source].name > b [data_source].name) {
      return 1;
    }
    else {
      return 0;
    }
  });

  $.each(data, function(index) {
    select_box.append(generate_option(data[index], "id", "name", data_source));
  });
  select_box.attr('disabled', '');
}

// Function to generate individual option tag
function generate_option(item, value, display, data_source){
  return '<option value="'+ item[data_source][value] +'">'+ item[data_source][display] +'</option>';
};

function handleChainedSelect() {
  // Handler for chained select
  $("[data-chains]").change(function(){
    current = $(this);
    chained = $($(this).parents("form").find(current.attr("data-chains")));
    data_type = chained.attr("data-type");

    loading = $("<div/>").attr({class: "span1 pull-right"}).html($("<img/>").attr({src: "/images/ajax-loader.gif"}));
    loading.insertAfter(chained);

    url = $(this).attr("data-path");
    if (url.indexOf(":id") == -1){
      url = url.replace("%3Aid", current.val());
    }
    else {
      url = url.replace(":id", current.val());
    }

    $.ajax({
      type: 'GET',
      url: url,
      dataType: 'json',
      success: function(data) {
        // Populate select with data returned
        populate_select(chained, data, data_type, generate_option);
      }, error: function(data, textStatus, XMLHttpRequest){
        current.val("");
        alert("Sorry, an error has occured. Please try again!");
      }, complete: function(jqXHR, textStatus){
        chained.removeAttr("disabled");
        loading.remove();
      }
    });
  });
}

$(document).ready(function(){
  handleChainedSelect();
});