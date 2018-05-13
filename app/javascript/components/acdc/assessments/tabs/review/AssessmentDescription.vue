<template>
  <div>
    <div class="section_heading flex-box">
      <span>Assessment Description</span>
      <div class="spacer"></div>
      <a v-if="!isSendForReview" class="button btn-warning btn-link" @click="changeCurrentTab">
        Edit
      </a>
    </div>
    <div class="content_body fs-14">
      <div class="p-8">
        <p class="clearfix">
          <strong class="large-5 black-9">Name: </strong>
          <span class="large-25 black-6">{{$store.state.AcdcStore.assessmentName}}</span>
        </p>
        <p class="clearfix">
          <strong class="large-5 black-9">Tools Selected: </strong>
          <span class="large-25 black-6">{{assessmentTools}}</span>
        </p>
        <p class="clearfix">
          <strong class="large-5 black-9">Functional Area: </strong>
          <span class="large-25 black-6">{{description.functional_area_id}}</span>
        </p>
        <p class="clearfix">
          <strong class="large-5 black-9">Experience: </strong>
          <span class="large-25 black-6">{{description.job_experience_id}}</span>
        </p>
        <p class="clearfix">
          <strong class="large-5 black-9">Proctoring: </strong>
          <span class="large-25 black-6">{{description.enable_proctoring ? 'Enabled' : 'Disabled'}}</span>
        </p>
      </div>  

    </div>
  </div>
</template>

<style lang="sass" scoped>
  @import '~assets/css/jit_review'        
</style>
<script>
  export default {
    props: ['description', 'tools', 'isSendForReview'],
    computed: {
      assessmentTools: function () {
        let tools = "NON-VAC("
        if(this.tools != null) {
          for(var k=0; k<this.tools.length; k++) {
            let lower = this.tools[k].split('_').join(' ')
            tools = tools + lower.charAt(0).toUpperCase() + lower.substr(1)
            if((this.tools.length - 1) != k) {
              tools = tools + ', '
            }
          };
        }
        return tools + ")"
      }
    },
    methods: {
      changeCurrentTab() {
        this.$store.dispatch('setChangeCurrentTab', {
          currentTab: {text: 'Description', index: 0}
        })
      }
    }
  }
</script>