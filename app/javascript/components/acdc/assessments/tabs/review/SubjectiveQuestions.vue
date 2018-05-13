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
        <li class="p-8 line-height-1">
          Lorem ipsum Question text is simply dummy text of the printing and typesetting industry?
        </li>
        <li class="p-8 line-height-1">
          Lorem ipsum Question text is simply dummy text of the printing and typesetting industry?
        
        </li>
      </ol>
    </div>
  </div>
</template>

<style lang="sass" scoped>
  @import '~assets/css/jit_review'
</style>
<script>
  export default {
    props: ['selectSubjectiveQuestions', 'isSendForReview'],
    methods: {
      changeCurrentTab() {
        this.$store.dispatch('setChangeCurrentTab', {
          currentTab: {text: 'Select Subjective/ Objective Questions', index: 4}
        })
      }
    }
  }
</script>