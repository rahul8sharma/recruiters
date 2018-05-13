<template>
  <div>
    <div class="section_heading flex-box">
      <span>Report Configuration</span>
      <div class="spacer"></div>
      <a v-if="!isSendForReview" class="button btn-warning btn-link" @click="changeCurrentTab">
        Edit
      </a>
    </div>
    <div class="content_body black-5  fs-14">
     
      <p class="p-8">Standard Configuration chosen</p>
    
    </div>
  </div>
</template>

<style lang="sass" scoped>
  @import '~assets/css/jit_review'
</style>
<script>
  export default {
    props: ['reportConfiguration', 'isSendForReview'],
    methods: {
      changeCurrentTab() {
        this.$store.dispatch('setChangeCurrentTab', {
          currentTab: {text: 'Report Configuration', index: 6}
        })
      }
    }
  }
</script>