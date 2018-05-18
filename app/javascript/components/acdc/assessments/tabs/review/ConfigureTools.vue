<template>
  <div>
    <div class="section_heading flex-box">
      <span>Configure Tools</span>
      <div class="spacer"></div>
      <a v-if="!isSendForReview" class="button btn-warning btn-link" @click="changeCurrentTab">
        Edit
      </a>
    </div>
    <div class="content_body fs-14">
      <div class="divider-1"></div>
      <div v-for="(toolConfiguration, index) in assessmentData.tool_configuaration">
        <div class="sub_heading">{{index + 1}}. {{splitToolsName([assessmentData.tools[index]])}}</div>
        <div class="p-8">
          <div v-if="assessmentData.tools[index] == 'psychometry'">
            <p class="clearfix">
              <em class="fs-12 black-6 large-11 show">
                (lorem ipsum text for psychometry help item for better understanding of the candidate. Helptext is in Hinglish Language)
              </em>
            </p>
            <p class="clearfix">
              <strong class="large-5 black-9">Assessment Type: </strong>
              <span class="large-25 black-6">{{toolConfiguration.candidate_stage == 'employee' ? 'Development' : 'Hiring'}}</span>
            </p>
            <p class="clearfix">
              <strong class="large-5 black-9">Assessment Class: </strong>
              <span class="large-25 black-6">{{toolConfiguration.assessment_type == 'competency' ? 'Competency' : 'Trait'}}</span>
            </p>
            <p class="clearfix">
              <strong class="large-5 black-9">Language: </strong>
              <span class="large-25 black-6">{{getlanguages(toolConfiguration)}}</span>
            </p>
            <p class="clearfix">
              <strong class="large-5 black-9">Page Size: </strong>
              <span class="large-25 black-6">{{toolConfiguration.page_size.text}}</span>
            </p>
            <p class="clearfix">
              <strong class="large-5 black-9">Help Text: </strong>
              <span class="large-25 black-6">{{toolConfiguration.show_help_text ? 'Yes' : 'No'}}</span>
            </p>
            <p class="clearfix">
              <strong class="large-5 black-9">Applicant ID: </strong>
              <span class="large-25 black-6">{{toolConfiguration.set_applicant_id ? 'Required' : 'Not Required'}}</span>
            </p>
          </div>
          <div v-if="assessmentData.tools[index] == 'bhive_with_hire_me'">
            <p class="clearfix">
              <strong class="large-5 black-9">Access Code: </strong>
              <span class="large-25 black-6">{{toolConfiguration.access_code}}</span>
            </p>
          </div>
          <div v-if="assessmentData.tools[index] == 'mini_hive_with_pearson_ravens' || assessmentData.tools[index] == 'mini_hive_with_wg'">
            <p class="clearfix">
              <strong class="large-5 black-9">Redirection URL: </strong>
              <span class="large-25 black-6">{{toolConfiguration.url}}</span>
            </p>
            <p class="clearfix">
              <strong class="large-5 black-9">Thank you page: </strong>
              <span v-html="toolConfiguration.thank_you_message" class="large-25 black-6"></span>
            </p>
          </div>
          <div v-if="assessmentData.tools[index] == 'bhive_with_cocubes'">
            <p class="clearfix">
              <strong class="large-5 black-9">Assessment Flow: </strong>
              <span class="large-25 black-6">{{toolConfiguration.assessment_flow}}</span>
            </p>
          </div>
          <p v-if="'is_sectional_score' in toolConfiguration" class="clearfix">
            <strong class="large-5 black-9">Sectional Scores: </strong>
            <span class="large-25 black-6">{{toolConfiguration.is_sectional_score ? 'Yes' : 'No'}}</span>
          </p>
          <p v-if="'aptitude_assessment' in toolConfiguration" class="clearfix">
            <strong class="large-5 black-9">Aptitude Assessment: </strong>
            <span class="large-25 black-6">{{toolConfiguration.aptitude_assessment.text}}</span>
          </p>
          <p v-if="'tool_weightage' in toolConfiguration" class="clearfix">
            <strong class="large-5 black-9">Tool Weightage: </strong>
            <span class="large-25 black-6">{{toolConfiguration.tool_weightage}}</span>
          </p>
        </div>
        <div class="divider-1"></div>
      </div>
    </div>
  </div>
</template>

<style lang="sass" scoped>
  @import '~assets/css/jit_review'
</style>
<script>
  import assessmentHelper from 'helpers/assessment.js'

  export default {
    props: ['assessmentData', 'isSendForReview'],
    methods: {
      changeCurrentTab() {
        this.$store.dispatch('setChangeCurrentTab', {
          currentTab: {text: 'Configure Tools', index: 1}
        })
      },
      splitToolsName(tools) {
        return assessmentHelper.splitToolsName(tools)
      },
      getlanguages(tool_configurations) {
        return assessmentHelper.getlanguages(tool_configurations)
      }
    }
  }
</script>