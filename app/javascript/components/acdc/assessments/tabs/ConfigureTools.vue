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
        this.$store.dispatch('updateAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          acdc_assessment: {tool_configuration: this.tabData.raw_data}
        })
      }
    },
    watch: {
      tabData: {
         handler(val){
           if(Object.keys(this.tabData.raw_data).length !== 0) {
            for(var k=0; k<this.tabData.tools.length; k++) {
              if(this.tabData.tools[k] == 'psychometry') {
                this.isSaveNextButtonDisabled = this.tabData.raw_data[k].languages.length == 0
                  || this.tabData.raw_data[k].assessment_type == ''
                  || this.tabData.raw_data[k].candidate_stage == ''
                  || this.tabData.raw_data[k].page_size.text == ''
              } else if(this.tabData.tools[k] == 'bhive_with_hire_me') {
                this.isSaveNextButtonDisabled = this.tabData.raw_data[k].access_code == ''
              } else if(this.tabData.tools[k] == 'bhive_with_cocubes') {
                this.isSaveNextButtonDisabled = this.tabData.raw_data[k].assessment_flow == ''
              } else if(this.tabData.tools[k] == 'bhive_with_jombay_aptitude') {
                this.isSaveNextButtonDisabled = this.tabData.raw_data[k].aptitude_assessment.text == ''
              } else if(this.tabData.tools[k] == 'mini_hive_with_pearson_ravens') {
                this.isSaveNextButtonDisabled = this.tabData.raw_data[k].url == ''
                  || this.tabData.raw_data[k].thank_you_message == ''
              } else if(this.tabData.tools[k] == 'mini_hive_with_jombay_critical_thinking') {
                this.isSaveNextButtonDisabled = this.tabData.raw_data[k].aptitude_assessment.text == ''
              } else if(this.tabData.tools[k] == 'mini_hive_with_wg') {
                this.isSaveNextButtonDisabled = this.tabData.raw_data[k].url == ''
                  || this.tabData.raw_data[k].thank_you_message == ''
              }
              if (this.isSaveNextButtonDisabled) {
                break;
              }
            }
          }
        },
        deep: true
      }
    }
  }
</script>