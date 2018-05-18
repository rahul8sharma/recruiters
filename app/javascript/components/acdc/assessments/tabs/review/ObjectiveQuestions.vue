<template>
  <div>
    <div class="section_heading flex-box">
      <span>Objective Questions</span>
      <div class="spacer"></div>
      <a v-if="!isSendForReview" class="button btn-warning btn-link" @click="changeCurrentTab">
        Edit
      </a>
    </div>
    <div class="content_body fs-14">
      <div class="divider-1"></div>
      <div v-for="(section, sectionIndex) in sections">
        <div class="sub_heading">{{section.section_name}}</div>
        <div class="divider-1"></div>
        <ul class="pb-15">
          <li class="p-8 line-height-1" v-for="(question, questionIndex) in section.data">
            <strong class="black-9">{{questionIndex + 1}}. {{question.question_body}}</strong>
            <div class="black-5" v-for="(option, optionsIndex) in question.options">{{optionsIndex + 1}}. {{option.body}}</div>
          </li>
        </ul>
      </div>
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
      sections: function () {
        return this.assessmentData.select_subjective_objective_questions.objective_question.sections
      }
    }
  }
</script>