<template>
  <div>
    <div class="action_bar">
      <div v-if="isAssessmentClassCompetency">
        <a>Add Traits</a>
      </div>
      <div v-else class="fs-16 black-9 link_breadcrumb uppercase">
        <a @click="changeComponent('Competencies')" v-bind:class="{active:currentComponent == 'Competencies'}">A. Add Competencies</a>
        <a @click="changeComponent('CompetencyTraits')" v-bind:class="{active:currentComponent == 'CompetencyTraits'}">B. Add Traits</a>
      </div>


      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div v-if="isAssessmentClassCompetency" class="text_container">
            This step allows you to add traits to the assessment. Please refer to the mapping given by Consulting team while performing this step.
          </div>
          <div v-else class="text_container">
            This step allows you to add competencies and traits to the assessment. Please refer to the mapping given by Consulting team while performing this step.
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
      <div v-if="isAssessmentClassCompetency">
        <Traits v-bind:tabData='tabData.raw_data'></Traits>
      </div> 
      <div v-else>
        <Competencies
          v-bind:tabData='tabData.raw_data'
          v-bind:is="currentComponent"
        ></Competencies>
      </div>  
    </div>
  </div>
</template>

<script>
  import Competencies from 'components/acdc/assessments/tabs/add_behaviours_competencies_traits/AddCompetencies.vue'
  import CompetencyTraits from 'components/acdc/assessments/tabs/add_behaviours_competencies_traits/AddCompetenciesAndTraits.vue'
  import Traits from 'components/acdc/assessments/tabs/add_behaviours_competencies_traits/AddTraits.vue'
  import assessmentHelper from 'helpers/assessment.js'
  import validationHelper from 'helpers/validation.js'

  export default {
    props: ['tabData'],
    data () {
      return {
        currentComponent: 'Competencies',
        isSaveNextButtonDisabled: true
      }
    },
    components: {
      Competencies, CompetencyTraits, Traits
    },
    methods: {
      changeComponent (name) {
        this.currentComponent = name
      },
      saveAndNext() {
        for(var competencyIndex = 0; competencyIndex < this.tabData.raw_data.competencies.length; competencyIndex ++) {
            let hashCount = {}
          for(var factor in this.tabData.raw_data.competencies[competencyIndex].selectedFactors) {
            let factorName = this.tabData.raw_data.competencies[competencyIndex].selectedFactors[parseInt(factor)].name
            for(var completeCompetencyIndex = 0; completeCompetencyIndex< this.tabData.raw_data.competencies.length; completeCompetencyIndex++) {
              for(var completeTraitIndex = 0; completeTraitIndex < this.tabData.raw_data.competencies[completeCompetencyIndex].selectedFactors.length; completeTraitIndex++) {
                if(factorName == this.tabData.raw_data.competencies[completeCompetencyIndex].selectedFactors[completeTraitIndex].name) {

                  hashCount[factorName] == undefined ? hashCount[factorName] = 0 : hashCount[factorName] = hashCount[factorName] + 1
                  if(hashCount[factorName] > 0) {
                    this.tabData.raw_data.competencies[completeCompetencyIndex].selectedFactors[completeTraitIndex].to_norm_bucket = this.tabData.raw_data.competencies[competencyIndex].selectedFactors[parseInt(factor)].to_norm_bucket

                    this.tabData.raw_data.competencies[completeCompetencyIndex].selectedFactors[completeTraitIndex].from_norm_bucket = this.tabData.raw_data.competencies[competencyIndex].selectedFactors[parseInt(factor)].from_norm_bucket
                  }
                }
              }
            }
          }
        }

        let assessmentTabSaved = this.$store.state.AcdcStore.assessmentTabSaved
        assessmentTabSaved.select_subjective_objective_questions = true
        this.$store.dispatch('updateAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          acdc_assessment: {
            add_behaviours_competencies_traits: this.tabData.raw_data,
            raw_data: assessmentTabSaved
          }
        })
      }
    },
    watch: {
      tabData: {
        handler(val){
          this.isSaveNextButtonDisabled = validationHelper.isTraitAndCompetencyTabValid(this.tabData.raw_data, this.isAssessmentClassCompetency)
        },
        deep: true
      }
    },
    computed: {
      isAssessmentClassCompetency () {
        if(Object.keys(this.$store.state.AcdcStore.assessmentRawData).length !== 0) {
          return assessmentHelper.isAssessmentClassCompetency(this.$store.state.AcdcStore.assessmentRawData)
        } else {
          return false
        }
      }
    },
    created: function() {
      this.isSaveNextButtonDisabled = validationHelper.isTraitAndCompetencyTabValid(this.tabData.raw_data, this.isAssessmentClassCompetency)
    }
  }
</script>