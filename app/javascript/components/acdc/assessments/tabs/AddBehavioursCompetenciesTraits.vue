<template>
  <div>
    <div class="action_bar">
      <div v-if="false">
        <a href="">Add Traits</a>
      </div>
      <div v-else class="fs-16 black-9 link_breadcrumb uppercase">
        <a @click="changeComponent('Competencies')" v-bind:class="{active:currentComponent == 'Competencies'}">A. Add Competencies</a>
        <a @click="changeComponent('CompetencyTraits')" v-bind:class="{active:currentComponent == 'CompetencyTraits'}">B. Add Behaviours</a>
      </div>


      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos necessitatibus, facilis dolorum, impedit fugit voluptatibus nemo unde ut a dolore vero quo sint perspiciatis. Exercitationem saepe cum a vitae! Eligendi.
          </div>
        </div>
      </div>
     
      <button class="button btn-warning uppercase fs-14" @click="saveAndNext">
        Save &amp; Next
      </button>
    </div>
    
    <div class="edit_section">
      <!-- TODO need to Update if condition -->
      <div v-if="false">
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

  export default {
    props: ['tabData'],
    data () {
      return {
        currentComponent: 'Competencies',
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
    }
  }
</script>