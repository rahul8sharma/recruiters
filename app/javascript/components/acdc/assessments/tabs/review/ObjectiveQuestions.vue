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
      <div class="sub_heading">Section One Name</div>
      <div class="divider-1"></div>
      <ul class="pb-15"> 
        <li class="p-8 line-height-1">
          <strong class="black-9">1. Lorem ipsum Question text is simply dummy text of the printing and typesetting industry?</strong>
          <div class="black-5">A. It is a long established fact that a reader will be distracted by the readable content of a page.</div>
        </li>
        <li class="p-8 line-height-1">
          <strong class="black-9">1. Lorem ipsum Question text is simply dummy text of the printing and typesetting industry?</strong>
          <div class="black-5">A. It is a long established fact that a reader will be distracted by the readable content of a page.</div>
        </li>
      </ul>

      <div class="sub_heading">Section Two Name</div>
      <div class="divider-1"></div>
      <ul class="pb-15"> 
        <li class="p-8 line-height-1">
          <strong class="black-9">1. Lorem ipsum Question text is simply dummy text of the printing and typesetting industry?</strong>
          <div class="black-5">A. It is a long established fact that a reader will be distracted by the readable content of a page.</div>
        </li>
        <li class="p-8 line-height-1">
          <strong class="black-9">1. Lorem ipsum Question text is simply dummy text of the printing and typesetting industry?</strong>
          <div class="black-5">A. It is a long established fact that a reader will be distracted by the readable content of a page.</div>
        </li>
      </ul>


    </div>
  </div>
</template>

<style lang="sass" scoped>
  @import '~assets/css/jit_review'
</style>
<script>
  export default {
    props: ['selectObjectiveQuestions', 'isSendForReview'],
    methods: {
      changeCurrentTab() {
        this.$store.dispatch('setChangeCurrentTab', {
          currentTab: {text: 'Select Subjective/ Objective Questions', index: 4}
        })
      }
    }
  }
</script>