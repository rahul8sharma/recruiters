// Pseudo multiselect implementation for preferred job category and
// preferred location
function initPseudoSelect(select, template, container, id_key, container_input_element){
  // select.change(function(){
    var selected_option = select.find("option:selected");
    var total_selected_options = $("[name='"+container_input_element+"']").length;
    var obj = {
      count: total_selected_options + 1,
      name: selected_option.text()
    };
    var id = select.val();
    obj[id_key] = id;
    select.val("");
    //selected_option.remove();
    var existingIds = $.map(container.find("[data-id]"), function(bubble){ 
      return parseInt($(bubble).attr("data-id"));
    });
      
    if($.inArray(parseInt(id), existingIds) == -1){
      $(template(obj)).appendTo(container);
    }
  // });
}

function initJobIndustryPseudoSelect(select) {
  if (select.length && (select.find("option:selected").val() != "")) {
    initPseudoSelect(
      select,
      Handlebars.compile($("#preferred-job_industry[type='text/x-template']").html()),
      $("[data-preferred-job_industry-container]"),
      "id",
      "basic[job_preferences][preferred_job_industries][query_options][id][]"
    );
  }
}

function initJobCategoryPseudoSelect(select) {  
  if (select.length && (select.find("option:selected").val() != "")) {
    initPseudoSelect(
      select,
      Handlebars.compile($("#preferred-job_category[type='text/x-template']").html()),
      $("[data-preferred-job_category-container]"),
      "id",
      "basic[job_preferences][preferred_job_categories][query_options][id][]"
    );
  }
}

function initJobProfilePseudoSelect(select) {
  if (select.length && (select.find("option:selected").val() != "")) {
    initPseudoSelect(
      select,
      Handlebars.compile($("#preferred-job_profile[type='text/x-template']").html()),
      $("[data-preferred-job_profile-container]"),
      "id",
      "basic[job_preferences][preferred_job_profiles][query_options][id][]"
    );
  }
}

function initJobLocationPseudoSelect(select) {
  if (select.length && (select.find("option:selected").val() != "")) {
    initPseudoSelect(
      select,
      Handlebars.compile($("#preferred-job_location[type='text/x-template']").html()),
      $("[data-preferred-job_location-container]"),
      "id",
      "basic[job_preferences][preferred_job_locations][query_options][id][]"
    );
  }
}

function workexSlider() {
  // Enable slider for abilities
  $("[data-work-ex-level]").slider({
    from: 1,
    to: 10,
    step: 1,
    limits: false,
    smooth: false,
    scale: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    skin: "round_plastic"
  });
}

$(function() {

  $("select[data-job_industry_pseudo_select]").on("change", function() {
  	initJobIndustryPseudoSelect($(this));
  });
  $("select[data-job_category_pseudo_select]").on("change", function() {
  	initJobCategoryPseudoSelect($(this));
  });
  $("select[data-job_profile_pseudo_select]").on("change", function() {
  	initJobProfilePseudoSelect($(this));
  });
  $("select[data-job_location_pseudo_select]").on("change", function() {
  	initJobLocationPseudoSelect($(this));
  });

  workexSlider();

  var chainedSelect = function(current, chainedSelectSelector, url, prompt, postCallback){
    if(!current.val()){
      return;
    }
    var chained = current.parents("form").find(chainedSelectSelector);
    
    current.attr("disabled", "disabled");
    chained.attr("disabled", "disabled");

    var loading = $("<div/>").attr({class: "span1 pull-right"}).html($("<img/>").attr({src: "/images/ajax-loader.gif"}));
    loading.insertAfter(chained);

    if (url.indexOf(":id") == -1){
      url = url.replace("%3Aid", current.val());
    }
    else {
      url = url.replace(":id", current.val());
    }
    var data_type = chained.attr("data-type");

    $.ajax({
      type: 'GET',
      url: url,
      dataType: 'json',
      success: function(data) {
      	console.log("in success");
        populate_select(chained, data, data_type, generate_option, prompt);
        if(postCallback){
          postCallback();
        }
      }, error: function(data, textStatus, XMLHttpRequest){
        current.val("");
        alert("Sorry, an error has occured. Please try again!");
      }, complete: function(jqXHR, textStatus){
        chained.removeAttr("disabled");
        current.removeAttr("disabled");
        loading.remove();
      }
    });
  };

  // $("select[data-job-category]").on("change", function() {
  // 	// console.log($(this));
  // 	initCategoryPseudoSelect($(this));
  //   // var that = $(this);
  //   // chainedSelect(
  //   //   that,
  //   //   "select[data-job-profile]",
  //   //   that.attr("data-path"),
  //   //   'Choose job profile',
  //   //   function(){
  //   //     var nextSelect = that.parents("form").find("select[data-job-profile]");
  //   //     if(nextSelect.attr('data-preselect')){
  //   //       nextSelect.val(nextSelect.attr("data-preselect"));
  //   //       setTimeout(function(){
  //   //         nextSelect.change();
  //   //         nextSelect.removeAttr('data-preselect');
  //   //       }, 1)
  //   //     }
  //   //   }
  //   // );
  // });

  // $("select[data-job-profile]").on("change", function() {
  // 	// Enable pseudo multiselect for preferred job_profile
  //   initJobProfilePseudoSelect();
  // });
});