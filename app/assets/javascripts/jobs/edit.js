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
      "job[industries][query_options][id][]"
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
      "job[categories][query_options][id][]"
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
      "job[profiles][query_options][id][]"
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
      "job[locations][query_options][id][]"
    );
  }
}

function initMustSkillPseudoSelect(select) {
  if (select.length && (select.find("option:selected").val() != "")) {
    initPseudoSelect(
      select,
      Handlebars.compile($("#must_skill_display_template[type='text/x-template']").html()),
      $("[data-preferred-must_skill-container]"),
      "id",
      "job[skills][must][query_options][id][]"
    );
  }
}

function initNiceSkillPseudoSelect(select) {
  if (select.length && (select.find("option:selected").val() != "")) {
    initPseudoSelect(
      select,
      Handlebars.compile($("#nice_skill_display_template[type='text/x-template']").html()),
      $("[data-preferred-nice_skill-container]"),
      "id",
      "job[skills][nice][query_options][id][]"
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

/*=== VALIDATIONS starts ===*/
$.validator.addMethod("check_presence", function(value, element, params) {
  var form = $(element).parents("form");
  var elem_legth = form.find("[name='"+params+"']").length;
  return elem_legth > 0;
}, "Please select at least one.");

$.validator.addMethod("chronological", function(value, element, params) {
  var form = $(element).parents("form");

  var salaryFrom = parseInt(form.find("[name='" + params.from.salary + "']").val());
  var salaryTo = parseInt(form.find("[name='" + params.to.salary + "']").val());
  
  if(isNaN(salaryFrom) || isNaN(salaryTo)){
    return this.optional(element);
  }
  else{
    return (salaryFrom <= salaryTo);
  }
}, "Invalid range");

function setupJobDetailsValidations() {
  $("form[data-job_details]").validate(
    $.extend(
      {
        ignore: "",
        rules: {
          "job_title": {
            required: true
          },
          "job_industry_ids": {
            check_presence: "job[industries][query_options][id][]"
          },
          "job_category_ids": {
            check_presence: "job[categories][query_options][id][]"
          },
          "job_profile_ids": {
            check_presence: "job[profiles][query_options][id][]"
          },
          "job_openings": {
            required: true
          },
          "job_location_ids": {
            check_presence: "job[locations][query_options][id][]"
          }
        },
        errorPlacement: function(error, element) {
          error.insertAfter($(element).siblings("br"));
        },
        submitHandler: function(form) {
          // form = $(form);
          // var skill_select = form.find("select[name='skill']");
          // var level_select = form.find("select[name='level']");
          // var experience_select = form.find("select[name='experience']");

          // var skillId = skill_select.val();
          // var skill = {
          //   name: skill_select.find("option:selected").text(),
          //   id: skillId,
          //   level_display: level_select.find("option:selected").text(),
          //   level_value: level_select.val(),
          //   experience: experience_select.val()
          // };

          // //skill_select.find("option[value='" + skill.id + "']").remove();
          // skill_select.val("");
          // level_select.val("");
          // experience_select.val("");

          // var skillsContainer = $("[data-domain-skills='true']");
          // skillsContainer.find("[data-skill='" + skillId + "']").remove();
          // $(skill_template(skill)).prependTo($("[data-domain-skills-wrapper]"));
          // $("form[data-domain-skills='true']").valid();
          return false;
        }
      }, bootstrap_error_settings
    )
  );
}

function setupHiringPreferencesValidations() {
  $("form[data-hiring_preferences]").validate(
    $.extend(
      {
        ignore: "",
        rules: {
          "job[traits][query_options][id][]": {
            maxlength: 6
          }
        },
        messages: {
          "job[traits][query_options][id][]": "Please select exactly 6"
        },
        // errorPlacement: function(error, element) {
        //   error.insertAfter($(element).siblings("br"));
        // },
        submitHandler: function(form) {
          return false;
        }
      }, bootstrap_error_settings
    )
  );
}

var logistics_validation_options = function() {
  var options = $.extend(
  {
    ignore: "",
    rules: {
      "kind_of_job": {
        required: true
      }
    },
    submitHandler: function(form) {
      return false;
    }
  }, bootstrap_error_settings);
  function min_sal_validation() {
    options.rules["min_salary"] = {
      required: true,
      number: true
    };
  }
  function max_sal_validation() {
    options.rules["max_salary"] = {
      required: true,
      number: true,
      chronological : {
        from : {
          salary: "min_salary"
        },
        to : {
          salary: "max_salary"
        }
      }
    }
  }
  min_sal_validation();max_sal_validation();
  return options;
}

function setupLogisticsValidations() {
  $("form[data-logistics]").validate(logistics_validation_options());
}

function setupCompanyDetailsValidations() {
  $("form[data-company_details]").validate(
    $.extend(
      {
        ignore: "",
        rules: {
          "company_name": {
            required: true
          },
          "company_location": {
            required: true
          }
        },
        errorPlacement: function(error, element) {
          error.insertAfter($(element).siblings("br"));
        },
        submitHandler: function(form) {
          console.log("test");
          return false;
        }
      }, bootstrap_error_settings
    )
  );
}

function setupEmployerDetailsValidations() {
  $("form[data-employer_details]").validate(
    $.extend(
      {
        ignore: "",
        rules: {
          "hr_name": {
            required: true
          },
          "contact_number": {
            required: true
          },
          "email": {
            required: true,
            email: true
          }
        },
        errorPlacement: function(error, element) {
          error.insertAfter($(element).siblings("br"));
        },
        submitHandler: function(form) {
          return false;
        }
      }, bootstrap_error_settings
    )
  );
}
/*=== VALIDATIONS ends ===*/

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
  $("select[data-must_skill_pseudo_select]").on("change", function() {
    if($("[data-must_skill_degree_diploma]").val() != "") {
      initMustSkillPseudoSelect($(this));
    }
  });
  $("select[data-nice_skill_pseudo_select]").on("change", function() {
    initNiceSkillPseudoSelect($(this));
  });

  workexSlider();

  setupJobDetailsValidations();
  setupHiringPreferencesValidations();
  setupLogisticsValidations();
  setupCompanyDetailsValidations();
  setupEmployerDetailsValidations();

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
  // 	// Enablree pseudo multiselect for preferred job_profile
  //   initJobProfilePseudoSelect();
  // });

  $("[name='logistics[][salary_range]']").on("change", function() {
    var selected = $(this).val();
    console.log(selected);
    if(selected == 1) {
      $("[data-salary]").removeAttr("disabled");
    } else {
      $("[data-salary]").attr("disabled", true);
    }
  });
});