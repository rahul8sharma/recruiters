<template>
  <div class="edit_section">
    <component
      v-for="(questionType, index) in tabData"
      v-bind:is="Object.keys(questionType)[0]"
      v-bind:objectiveQuestion="tabData.raw_data[Object.keys(questionType)[0]]"
    >
    </component>

    <component
      v-for="(questionType, index) in tabData"
      v-bind:is="Object.keys(questionType)[1]"
      v-bind:subjectiveQuestion="tabData.raw_data[Object.keys(questionType)[1]]"
    >
    </component>
    <div class="divider-4"></div>
  </div>
</template>

<script>
  import objective_question from 'components/acdc/assessments/tabs/select_questions/ObjectiveQuestions.vue'
  import subjective_question from 'components/acdc/assessments/tabs/select_questions/SubjectiveQuestions.vue'
  export default {
    props: ['tabData'],
    components: { objective_question,  subjective_question }
  }
</script>