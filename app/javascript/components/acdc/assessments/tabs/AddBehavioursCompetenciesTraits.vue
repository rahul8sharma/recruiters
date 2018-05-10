<template>
  <div class="edit_section">
    <!-- TODO need to Update if condition -->
    <div v-if="false">
      <Traits v-bind:tabData='tabData.raw_data'></Traits>
    </div> 
    <div v-else>
      <button @click="changeComponent('Competencies')">Competencies</button>
      <button @click="changeComponent('CompetencyTraits')">Traits</button>
      <Competencies
        v-bind:tabData='tabData.raw_data'
        v-bind:is="currentComponent"
      ></Competencies>
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
      }
    }
  }
</script>