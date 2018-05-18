<template>
  <div>
    <div class="section_heading flex-box">
      <span>Subjective Questions</span>
      <div class="spacer"></div>
      <a v-if="!isSendForReview" class="button btn-warning btn-link" @click="changeCurrentTab">
        Edit
      </a>
    </div>
    <div class="content_body fs-14">
      <div class="divider-1"></div>
      <ol class="pb-15 black-9">
        <li class="p-8 line-height-1"  v-for="(question, questionIndex) in questions"> {{question}} </li>
      </ol>
    </div>
  </div>
</template>

<style lang="sass" scoped>
  @import '~assets/css/jit_review'
</style>
<script>
  export default {
    props: ['assessmentData', 'isSendForReview'],
    methods: {
      changeCurrentTab() {
        this.$store.dispatch('setChangeCurrentTab', {
          currentTab: {text: 'Select Subjective/ Objective Questions', index: 4}
        })
      }
    },
    computed: {
      questions: function () {
        return this.assessmentData.select_subjective_objective_questions.subjective_question.questions
      }
    }
  }
</script>