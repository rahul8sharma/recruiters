<template>
  <div>
    <div class="action_bar">
      <div class="fs-16 black-9 bold">Follow these steps to configure every tool</div>

      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            This step lists the tools which will be used in the assessment. Select the configuration of the tools depending on your need.
          </div>
        </div>
      </div>
     
      <button 
        class="button btn-warning uppercase fs-14" 
        @click="saveAndNext"
        :disabled = "isSaveNextButtonDisabled"
      >
        Save &amp; Next
      </button>
    </div>

    <div class="edit_section">
      <component
        v-for="(currentTool, index) in currentTools"
        v-bind:is="currentTool"
        v-bind:key="index"
        v-bind:configureToolData="tabData.raw_data[index]"
        v-bind:index="index + 1"
      >
      </component>
      <div class="divider-4"></div>
    </div>

  </div>
</template>

<script>
  import bhive_with_cocubes from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithCoCubes.vue';
  import bhive_with_hire_me from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithHireMe.vue';
  import bhive_with_jombay_aptitude from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithJombayAptitude.vue';
  import mini_hive_with_jombay_abstract_thinking from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithJombayAbstractThinking.vue';
  import mini_hive_with_jombay_critical_thinking from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithJombayCriticalThinking.vue';
  import mini_hive_with_pearson_ravens from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithPearsonRavens.vue';
  import mini_hive_with_wg from 'components/acdc/assessments/tabs/configure_tools/Mini-HIVEwithWG.vue';
  import psychometry from 'components/acdc/assessments/tabs/configure_tools/Psychometry.vue';
  import validationHelper from 'helpers/validation.js'
 
  export default {
    props: ['tabData'],
    components: {
      bhive_with_cocubes, bhive_with_hire_me,
      bhive_with_jombay_aptitude,
      mini_hive_with_jombay_abstract_thinking,
      mini_hive_with_jombay_critical_thinking,
      mini_hive_with_pearson_ravens,
      mini_hive_with_wg,
      psychometry
    },
    data () {
      return {
        isSaveNextButtonDisabled: true
      }
    },
    computed: {
      currentTools: function () {
        return this.tabData.tools
      },
    },
    methods: {
      saveAndNext() {
        let assessmentTabSaved = this.$store.state.AcdcStore.assessmentTabSaved
        assessmentTabSaved.create_custom_forms = true
        this.$store.dispatch('updateAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          acdc_assessment: {
            tool_configuration: this.tabData.raw_data,
            raw_data: assessmentTabSaved
          }
        })
      }
    },
    watch: {
      tabData: {
        handler(val){
          this.isSaveNextButtonDisabled = validationHelper.isConfigureToolsTabValid(this.tabData.raw_data, this.tabData.tools)
        },
        deep: true
      }
    },
    created: function() {
      this.isSaveNextButtonDisabled = validationHelper.isConfigureToolsTabValid(this.tabData.raw_data, this.tabData.tools)
    }
  }
</script>