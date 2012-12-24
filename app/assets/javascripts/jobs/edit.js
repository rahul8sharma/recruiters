// Pseudo multiselect implementation for preferred job category and
// preferred location
function initPseudoSelect(select, template, container, id_key){
  var selected_option = select.find("option:selected");
  var obj = {
    name: selected_option.text()
  };
  var id = select.val();
  obj[id_key] = id;
  select.val("");

  var existingIds = $.map(container.find("[data-snippet]"), function(bubble){ 
    return parseInt($(bubble).attr("data-snippet"));
  });
      
  if($.inArray(parseInt(id), existingIds) == -1) {
    $(template(obj)).appendTo(container);
  }
}

function initJobIndustryPseudoSelect(select) {
  if (select.length && (select.find("option:selected").val() != "")) {
    initPseudoSelect(
      select,
      Handlebars.compile($("#preferred-job_industry[type='text/x-template']").html()),
      $("[data-preferred-job_industry-container]"),
      "id"
    );
  }
}

function initJobCategoryPseudoSelect(select) {  
  if (select.length && (select.find("option:selected").val() != "")) {
    initPseudoSelect(
      select,
      Handlebars.compile($("#preferred-job_category[type='text/x-template']").html()),
      $("[data-preferred-job_category-container]"),
      "id"
    );
  }
}

function initJobProfilePseudoSelect(select) {
  if (select.length && (select.find("option:selected").val() != "")) {
    initPseudoSelect(
      select,
      Handlebars.compile($("#preferred-job_profile[type='text/x-template']").html()),
      $("[data-preferred-job_profile-container]"),
      "id"
    );
  }
}

function initJobLocationPseudoSelect(select) {
  if (select.length && (select.find("option:selected").val() != "")) {
    initPseudoSelect(
      select,
      Handlebars.compile($("#preferred-job_location[type='text/x-template']").html()),
      $("[data-preferred-job_location-container]"),
      "id"
    );
  }
}

function initSkillTemplate() {
  window.skill_template = {
    must: Handlebars.compile($("#must_skill_display_template[type='text/x-template']").html())
  };
}

function initMustSkillPseudoSelect(select, skill) {
  if (select.length && (select.find("option:selected").val() != "")) {
    var container = $("[data-preferred-must_skill-container]");
    var snippet = container.find("[data-snippet]");
    var is_present = (snippet.attr("data-snippet") == skill.id);
    if(is_present) {
      snippet.remove();
    }
    $(skill_template.must(skill)).appendTo(container);
  }
}

function initNiceSkillPseudoSelect(select, skill) {
  if (select.length && (select.find("option:selected").val() != "")) {
    initPseudoSelect(
      select,
      Handlebars.compile($("#nice_skill_display_template[type='text/x-template']").html()),
      // skill_template.nice(skill)
      $("[data-preferred-nice_skill-container]"),
      "id"
    );
  }
}

// function workexSlider() {
//   // Enable slider for abilities
//   $("[data-work-ex-level]").slider();
//   $("[data-work-ex-level]").slider({
//     from: 1,
//     to: 10,
//     step: 1,
//     limits: false,
//     smooth: false,
//     scale: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
//     skin: "round_plastic"
//   });
// }

/*=== VALIDATIONS starts ===*/
$.validator.addMethod("check_presence", function(value, element, params) {
  var form = $(element).parents("form");
  var elem_legth = form.find("[name='"+params+"']").length;
  return elem_legth > 0;
}, "Please select at least one.");

$.validator.addMethod("chronological", function(value, element, params) {
  var form = $(element).parents("form");

  var From = parseInt(form.find("[name='" + params.from.range + "']").val());
  var To = parseInt(form.find("[name='" + params.to.range + "']").val());
  
  if(isNaN(From) || isNaN(To)){
    return this.optional(element);
  }
  else{
    return (From <= To);
  }
}, "Invalid range");

function setupJobDetailsValidations() {
  $("form[data-job_details]").validate(
    $.extend(
      {
        ignore: "",
        rules: {
          "name": {
            required: true
          },
          "job_industry_ids": {
            check_presence: "industries[]"
          },
          "job_category_ids": {
            check_presence: "categories[]"
          },
          "job_profile_ids": {
            check_presence: "profiles[]"
          },
          "job[total_openings]": {
            required: true
          },
          "job_location_ids": {
            check_presence: "locations[]"
          }
        },
        errorPlacement: function(error, element) {
          error.insertAfter($(element).siblings("br"));
        }
      }, bootstrap_error_settings
    )
  );
}

var job_requirements_validation_options = function() {
  var options = $.extend(
  {
    ignore: "",
    rules: {
      "qualification[degree_diploma][]": {
        required: true
      },
      "job_must_skill_ids": {
        check_presence: "skill[must][skill_id][]"
      }
    },
    errorPlacement: function(error, element) {
      error.insertAfter($(element).siblings("br"));
    }
  }, bootstrap_error_settings);
  function min_work_ex_validation() {
    options.rules["work_experience[min_range]"] = {
      required: true,
      number: true
    };
  }
  function max_work_ex_validation() {
    options.rules["work_experience[max_range]"] = {
      required: true,
      number: true,
      chronological : {
        from : {
          range: "work_experience[min_range]"
        },
        to : {
          range: "work_experience[max_range]"
        }
      }
    }
  }
  min_work_ex_validation();max_work_ex_validation();
  return options;
}

function setupJobRequirementsValidations() {
  $("form[data-job_requirements]").validate(job_requirements_validation_options());
}

function setupHiringPreferencesValidations() {
  $("form[data-hiring_preferences]").validate(
    $.extend(
      {
        ignore: "",
        rules: {
          "trait[]": {
            maxlength: 6
          }
        },
        messages: {
          "trait[]": "Please select exactly 6"
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
      "kind_of": {
        required: true
      }
    }
  }, bootstrap_error_settings);
  function min_sal_validation() {
    options.rules["salary[min_range]"] = {
      required: true,
      number: true
    };
  }
  function max_sal_validation() {
    options.rules["salary[max_range]"] = {
      required: true,
      number: true,
      chronological : {
        from : {
          range: "salary[min_range]"
        },
        to : {
          range: "salary[max_range]"
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
$.fn.serializeObject = function()
{
    var o = {};
    var a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};
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
          var params = $(form).serializeObject();
          console.log(params["company[name]"]);
          $("[data-employer_details] input[name='company[name]']").val(params["company[name]"]);
          $("[data-employer_details] input[name='company[description]']").val(params["company[description]"]);
          $("[data-employer_details] input[name='company[url]']").val(params["company[url]"]);
          $("[data-employer_details] input[name='company[address]']").val(params["company[address]"]);
          $("[data-employer_details] input[name='company[location][geography_id][]']").val(params["company[location][geography_id][]"]);
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
        }
      }, bootstrap_error_settings
    )
  );
}
/*=== VALIDATIONS ends ===*/

$(function() {

  initSkillTemplate();

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
      var skill = {
            name: $("[data-must_skill_degree_diploma]").find("option:selected").text(),
            id: $("[data-must_skill_degree_diploma]").val(),
            experience: $("select[data-must_skill_pseudo_select]").val()
          };
      initMustSkillPseudoSelect($(this), skill);
    }
  });
  $("select[data-nice_skill_pseudo_select]").on("change", function() {
    initNiceSkillPseudoSelect($(this));
  });

  // workexSlider();

  setupJobDetailsValidations();
  setupJobRequirementsValidations();
  setupHiringPreferencesValidations();
  setupLogisticsValidations();
  setupCompanyDetailsValidations();
  setupEmployerDetailsValidations();

  $.each($("[data-preselect]"), function(index, element) {
      element = $(element);
      element.val(element.attr("data-preselect"));
    }
  );

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

  function buildCompanyDetailsHash() {
    var company = {
      name: $("form[data-company_details] [data-setter-company-name]").val(),
      description: $("form[data-company_details] [data-setter-company-description]").val(),
      url: $("form[data-company_details] [data-setter-company-url]").val(),
      address: $("form[data-company_details] [data-setter-company-address]").val(),
      location: $("form[data-company_details] [data-setter-company-location]").val(),
      location_name: $("form[data-company_details] [data-setter-company-location] :selected").text()
    };
    return company;
  }

  function showElement(flag, element, value) {
    if(value) {
      $("form[data-company_details] [data-getter-company-"+element+"]").html(value)
    }
    if(flag) {
      $("form[data-company_details] [data-setter-company-"+element+"]").hide();
      $("form[data-company_details] [data-getter-company-"+element+"]").show();
    }
    else {
      $("form[data-company_details] [data-setter-company-"+element+"]").show();
      $("form[data-company_details] [data-getter-company-"+element+"]").hide();
    }
  }

  $("[data-edit_company_profile]").on("click", function(e) {
    $("form[data-company_details] button[type='submit']").removeClass("hide");
    $("form[data-company_details] [data-edit_company_profile]").remove();
    $("form[data-company_details] [name='contact[profile]']").removeAttr("disabled");
    showElement(false, "name");
    showElement(false, "description");
    showElement(false, "url");
    showElement(false, "address");
    showElement(false, "location");
    e.preventDefault();
  });

  function setUneditableContactDetails() {
    var company = buildCompanyDetailsHash();
    showElement(true, "name", company.name);
    showElement(true, "description", company.description);
    showElement(true, "url", company.url);
    showElement(true, "address", company.address);
    showElement(true, "location", company.location_name);

  }
  setUneditableContactDetails();

  $("[data-continue_later]").on("click", function(e) {
    var form = $("[data-job_posting_container]").find("[data-job_posting_form]");
    form.find("input[name='continue_later']").val("true");
    form.submit();
    e.preventDefault();
  });

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

  $("[name='work_experience[type]']").on("change", function() {
    var selected = $(this).val();
    if(selected == 1) {
      $("[data-work_exp]").removeAttr("disabled");
    } else {
      $("[data-work_exp]").attr("disabled", true);
    }
  });

  $("[name='salary[range][]']").on("change", function() {
    var selected = $(this).val();
    if(selected == 1) {
      $("[data-salary]").removeAttr("disabled");
    } else {
      $("[data-salary]").attr("disabled", true);
    }
  });

  $("[name='trait[]']").on("change", function() {
    if($(this).is(':checked')) {
      $(this).parents("label").addClass("active");
    } else {
      $(this).parents("label").removeClass("active");
    }
  });
});