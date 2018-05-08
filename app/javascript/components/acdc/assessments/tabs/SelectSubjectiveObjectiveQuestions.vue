<template>
  <div class="edit_section">
    <button @click="changeQuestionType()">Objective Question</button>
    <button @click="changeQuestionType()">Subjective Question</button>
    <component
      v-if="isObjective"
      v-for="(questionType, index) in tabData"
      v-bind:key="index"
      v-bind:is="Object.keys(questionType)[0]"
      v-bind:objectiveQuestion="tabData.raw_data[Object.keys(questionType)[0]]"
    >
    </component>

    <component
      v-if="!isObjective"
      v-for="(questionType, index) in tabData"
      v-bind:key="index"
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
    data () {
      return  {
        isObjective: true
      }
    },
    components: { objective_question,  subjective_question },
    methods: {
      changeQuestionType() {
        this.isObjective = !this.isObjective
      }
    }
  }
</script>