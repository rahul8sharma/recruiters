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
        this.$store.dispatch('updateAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          acdc_assessment: {add_behaviours_competencies_traits: this.tabData.raw_data}
        })
      }
    },
    watch: {
      tabData: {
        handler(val){
          if(this.isAssessmentClassCompetency) {
            this.isSaveNextButtonDisabled = isValidForm(this.tabData.raw_data.job_assessment_factor_norms_attributes, this.isAssessmentClassCompetency)
          } else {
            this.isSaveNextButtonDisabled = isValidForm(this.tabData.raw_data.competencies, this.isAssessmentClassCompetency)
          }
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
    }
  }

  function isValidForm(competenciesAndTrait, isAssessmentClassCompetency) {
    var isValid = true;
    for(var k=0; k<competenciesAndTrait.length; k++) {
      if (isAssessmentClassCompetency) {
        isValid = competenciesAndTrait[k].name == null
          || competenciesAndTrait[k].name == 'Select Trait'
          || competenciesAndTrait[k].name.length == 0 
          || competenciesAndTrait[k].weight.length == 0
        if (isValid) {
          break;
        }
      } else {
        var isTraitValid = true;
        for(var i=0; i<competenciesAndTrait[k].selectedFactors.length; i++) {
          isTraitValid = competenciesAndTrait[k].selectedFactors[i].weight.length == 0
            || competenciesAndTrait[k].selectedFactors[i].name == null
            || competenciesAndTrait[k].selectedFactors[i].name == 'Select Trait'
            || competenciesAndTrait[k].selectedFactors[i].name.length == 0
          if (isTraitValid) {
            break;
          }
        }
        isValid = competenciesAndTrait[k].name.length == 0
          || competenciesAndTrait[k].weight.length == 0
          || competenciesAndTrait[k].factor_ids.length == 0 || isTraitValid
        if (isValid) {
          break;
        }
      }
    }
    return isValid
  }
</script>