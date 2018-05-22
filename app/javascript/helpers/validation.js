// Check maxlength of field and validate.
function checkLengthInterval(fieldValue, maxLength) {
  return fieldValue.trim().length > maxLength || fieldValue.trim().length == 0
}

// Check, Is field empty
function isEmpty(fieldValue) {
  return fieldValue.trim().length == 0
}

// Check, Is JSON empty
function isJsonEmpty(JsonField) {
  return Object.keys(JsonField).length !== 0
}

// Validation for description tab
function isDescriptionTabValid(raw_data, assessment_name) {
	if(isJsonEmpty(raw_data)) {
    return checkLengthInterval(assessment_name, 20) || raw_data.industry_id.value == ""
  }

	return true
}

// Validation for configure tools tab
function isConfigureToolsTabValid(raw_data, tools) {
	var is_save_next_button_disabled = true
	if(isJsonEmpty(raw_data)) {
    for(var k=0; k<tools.length; k++) {
      if(tools[k] == 'psychometry') {
        is_save_next_button_disabled = raw_data[k].languages.length == 0
          || raw_data[k].assessment_type == ''
          || raw_data[k].candidate_stage == ''
          || raw_data[k].page_size.text == ''
      } else if(tools[k] == 'bhive_with_hire_me') {
        is_save_next_button_disabled = raw_data[k].access_code == ''
      } else if(tools[k] == 'bhive_with_cocubes') {
        is_save_next_button_disabled = raw_data[k].assessment_flow == ''
      } else if(tools[k] == 'bhive_with_jombay_aptitude') {
        is_save_next_button_disabled = raw_data[k].aptitude_assessment.text == ''
      } else if(tools[k] == 'mini_hive_with_pearson_ravens') {
        is_save_next_button_disabled = raw_data[k].url == ''
          || raw_data[k].thank_you_message == ''
      } else if(tools[k] == 'mini_hive_with_jombay_critical_thinking') {
        is_save_next_button_disabled = raw_data[k].aptitude_assessment.text == ''
      } else if(tools[k] == 'mini_hive_with_wg') {
        is_save_next_button_disabled = raw_data[k].url == ''
          || raw_data[k].thank_you_message == ''
      }
      if (is_save_next_button_disabled) {
        break;
      }
    }
  }

	return is_save_next_button_disabled
}

// Validation for custom form tab
function isCustomFormTabValid(raw_data) {
	if(isJsonEmpty(raw_data)) {
    return (raw_data.defined_form_id.value == null || raw_data.defined_form_id.value.length == 0 )
    	&& (raw_data.defined_form == null || Object.keys(raw_data.defined_form).length == 0)
  }

	return true
}

// Validation for trait and competency tab
function isTraitAndCompetencyTabValid(raw_data, isAssessmentClassCompetency) {
  var isValid = true;
	if(isJsonEmpty(raw_data)) {
    for(var k=0; k<raw_data.job_assessment_factor_norms_attributes.length; k++) {
      if (isAssessmentClassCompetency) {
        isValid = raw_data.job_assessment_factor_norms_attributes[k].name == null
          || raw_data.job_assessment_factor_norms_attributes[k].name == 'Select Trait'
          || raw_data.job_assessment_factor_norms_attributes[k].name.length == 0 
          || raw_data.job_assessment_factor_norms_attributes[k].weight.length == 0
        if (isValid) {
          break;
        }
      } else {
        var isTraitValid = true;
        for(var i=0; i<raw_data.competencies[k].selectedFactors.length; i++) {
          isTraitValid = raw_data.competencies[k].selectedFactors[i].weight.length == 0
            || raw_data.competencies[k].selectedFactors[i].name == null
            || raw_data.competencies[k].selectedFactors[i].name == 'Select Trait'
            || raw_data.competencies[k].selectedFactors[i].name.length == 0
          if (isTraitValid) {
            break;
          }
        }
        isValid = checkLengthInterval(raw_data.competencies[k].name, 20)
          || raw_data.competencies[k].weight.length == 0
          || raw_data.competencies[k].factor_ids.length == 0 || isTraitValid
        if (isValid) {
          break;
        }
      }
    }
  }

	return isValid
}

// Validation for template tab
function isTemplateTabValid(raw_data) {
	if(isJsonEmpty(raw_data)) {
    var isInvitationTemplateIdValid = true, isReminderTemplateIdValid = true
    if (raw_data.invitation_template_id != null ) {
      isInvitationTemplateIdValid = raw_data.invitation_template_id.length == 0
    }
    if (raw_data.reminder_template_id != null ) {
      isReminderTemplateIdValid = raw_data.reminder_template_id.length == 0
    }
    return (
        isInvitationTemplateIdValid
        && Object.keys(raw_data.create_invitation_template).length == 0
      ) || (
        isReminderTemplateIdValid
        && Object.keys(raw_data.create_reminder_template).length == 0
      )
  }

	return true
}

// Check all tab is valid to disable click on tab
function isTabValid(assessmentTabSaved, tab_url) {
  if (tab_url == 'description') {
    return assessmentTabSaved.description
  } else if (tab_url == 'tool_configuaration') {
    return assessmentTabSaved.tool_configuaration
  } else if (tab_url == 'create_custom_forms') {
    return assessmentTabSaved.create_custom_forms
  } else if (tab_url == 'add_behaviours_competencies_traits') {
    return assessmentTabSaved.add_behaviours_competencies_traits
  } else if (tab_url == 'select_subjective_objective_questions') {
    return assessmentTabSaved.select_subjective_objective_questions
  } else if (tab_url == 'select_template') {
    return assessmentTabSaved.select_template
  } else if (tab_url == 'report_configuration') {
    return assessmentTabSaved.report_configuration
  } else if (tab_url == 'review') {
    return assessmentTabSaved.review
  }
}

export default {
	checkLengthInterval, isEmpty, isDescriptionTabValid, isJsonEmpty,
	isConfigureToolsTabValid, isCustomFormTabValid, isTraitAndCompetencyTabValid,
	isTemplateTabValid, isTabValid
}