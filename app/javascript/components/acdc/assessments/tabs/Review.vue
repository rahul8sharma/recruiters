<template>
  <div>
    <div class="action_bar" v-bind:class="{hide:isSendForReview}">
      <div class="fs-16 black-9 bold">Review Assessment</div>

      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos necessitatibus, facilis dolorum, impedit fugit voluptatibus nemo unde ut a dolore vero quo sint perspiciatis. Exercitationem saepe cum a vitae! Eligendi.
          </div>
        </div>
      </div>
     
      <button class="button btn-warning uppercase fs-14" @click="sendForApproval()">
        SEND FOR APPROVAL
      </button>
    </div>

    <div class="edit_section p-0" v-if="Object.keys($store.state.AcdcStore.assessmentRawData).length !== 0">
      <div class="review_section">
        <AssessmentDescription 
          v-bind:description="assessmentData.description"
          v-bind:isSendForReview="isSendForReview"
          v-bind:tools="assessmentData.tools"
        >
        </AssessmentDescription>
      </div>
      <div class="review_section">
        <ConfigureTools
          v-bind:assessmentData="assessmentData"
          v-bind:isSendForReview="isSendForReview"
        >
        </ConfigureTools>
      </div>
      <div class="review_section">
        <CustomForms
          v-bind:createCustomForms="assessmentData.create_custom_forms"
          v-bind:isSendForReview="isSendForReview"
        >
        </CustomForms>         
      </div>
      <div class="review_section">
        <BehaviourCompetencyTraits
          v-bind:addBehavioursCompetenciesTraits="assessmentData.add_behaviours_competencies_traits"
          v-bind:isSendForReview="isSendForReview"
        >
        </BehaviourCompetencyTraits>         
      </div>
      <div class="review_section">
        <ObjectiveQuestions
          v-bind:selectObjectiveQuestions="assessmentData.select_questions"
          v-bind:isSendForReview="isSendForReview"
        >
        </ObjectiveQuestions>         
      </div>
      <div class="review_section">
        <SubjectiveQuestions
          v-bind:selectSubjectiveQuestions="assessmentData.select_questions"
          v-bind:isSendForReview="isSendForReview"
        >
        </SubjectiveQuestions>
      </div>
      <div class="review_section">
        <EmailTemplates
          v-bind:selectTemplates="assessmentData.select_templates"
          v-bind:isSendForReview="isSendForReview"
        >
        </EmailTemplates>         
      </div>
      <div class="review_section">
        <ReportConfiguration
          v-bind:reportConfiguration="assessmentData.report_configuration"
          v-bind:isSendForReview="isSendForReview"
        >
        </ReportConfiguration>         
      </div>

      <div class="divider-2"></div>

      <div class="review_actions">
        <button class="button btn-warning inverse fs-14 uppercase bold">Generate Sample Report</button>
      </div>
    </div>
  </div>
</template>
<style lang="sass" scoped>
  .review_actions
    border-top: 2px solid rgba(0, 0, 0, 0.1)
    padding: 10px 15px
    text-align: right

</style>
<script>
  import AssessmentDescription from 'components/acdc/assessments/tabs/review/AssessmentDescription.vue';
  import ConfigureTools from 'components/acdc/assessments/tabs/review/ConfigureTools.vue';
  import CustomForms from 'components/acdc/assessments/tabs/review/CustomForms.vue';
  import BehaviourCompetencyTraits from 'components/acdc/assessments/tabs/review/BehaviourCompetencyTraits.vue';
  import ObjectiveQuestions from 'components/acdc/assessments/tabs/review/ObjectiveQuestions.vue';
  import SubjectiveQuestions from 'components/acdc/assessments/tabs/review/SubjectiveQuestions.vue';
  import EmailTemplates from 'components/acdc/assessments/tabs/review/EmailTemplates.vue';
  import ReportConfiguration from 'components/acdc/assessments/tabs/review/ReportConfiguration.vue';
  export default {
    props: ['isSendForReview'],
    components: {
     AssessmentDescription,
     ConfigureTools, 
     CustomForms,
     BehaviourCompetencyTraits,
     ObjectiveQuestions,
     SubjectiveQuestions,
     EmailTemplates,
     ReportConfiguration
    },
    methods: {
      sendForApproval:function() {
        this.$store.dispatch('updateAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          acdc_assessment: {status: 'review'}
        }).then(() => {
          alert("Assessment Send For Approval")
          location.reload();
        })
      }
    },
    computed: {
      assessmentData: function () {
        return this.$store.state.AcdcStore.assessmentRawData
      }
    }
  }
</script>
<style lang="sass" scoped>
  .review_section
    border-bottom: 1px solid rgba(0, 0, 0, 0.1)
    padding: 25px 0
</style>