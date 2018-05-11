<template>
  <div>
    <div class="action_bar">
      <div class="fs-16 black-9 bold">Follow these steps to configure every tool</div>

      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos necessitatibus, facilis dolorum, impedit fugit voluptatibus nemo unde ut a dolore vero quo sint perspiciatis. Exercitationem saepe cum a vitae! Eligendi.
          </div>
        </div>
      </div>
     
      <button class="button btn-warning uppercase fs-14">
        SEND FOR APPROVAL
      </button>
    </div>

    <div class="edit_section p-0">
      <AssessmentDescription></AssessmentDescription> 
      <ConfigureTools></ConfigureTools> 
      <CustomForms></CustomForms> 
      <BehaviourCompetencyTraits></BehaviourCompetencyTraits> 
      <ObjectiveQuestions></ObjectiveQuestions> 
      <SubjectiveQuestions></SubjectiveQuestions> 
      <EmailTemplates></EmailTemplates> 
      <ReportConfiguration></ReportConfiguration> 

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
    components: {
     AssessmentDescription,
     ConfigureTools, 
     CustomForms,
     BehaviourCompetencyTraits,
     ObjectiveQuestions,
     SubjectiveQuestions,
     EmailTemplates,
     ReportConfiguration
    }
  }
</script>