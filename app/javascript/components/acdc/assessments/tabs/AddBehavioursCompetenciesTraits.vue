<template>
  <div>
    <div class="action_bar">
      <div class="fs-16 black-9 bold">Follow these steps to configure every tool</div>

      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos necessitatibus, facilis dolorum, impedit fugit voluptatibus nemo unde ut a dolore vero quo sint perspiciatis. Exercitationem saepe cum a vitae! Eligendi.
          </div>
        </div>
      </div>
     
      <button class="button btn-warning uppercase fs-14">
        Save &amp; Next
      </button>
    </div>
    
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