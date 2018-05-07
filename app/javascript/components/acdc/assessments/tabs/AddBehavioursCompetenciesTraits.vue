<template>
  <div class="edit_section">
    <button @click="changeComponent('Competencies')">Competencies</button>
    <button @click="changeComponent('CompetencyTraits')">Traits</button>
    <Competencies
      v-bind:competencies='competencies'
      v-bind:tabData='tabData.raw_data'
      v-bind:competencyNames='competencyNames'
      v-bind:is="currentComponent"
    ></Competencies>
  </div>
</template>

<script>
  import Competencies from 'components/acdc/assessments/tabs/add_behaviours_competencies_traits/AddCompetencies.vue'
  import CompetencyTraits from 'components/acdc/assessments/tabs/add_behaviours_competencies_traits/AddTraits.vue'

  export default {
    props: ['tabData'],
    data () {
      return {
        currentComponent: 'Competencies',
        competencies: [],
        competencyNames: [],
      }
    },
    components: {
      Competencies, CompetencyTraits
    },
    methods: {
      changeComponent (name) {
        this.currentComponent = name
      }
    },
    created: function() {
      // TODO need to update
     this.get.competencies({
      company_id: 2,
      functional_areas_id: 1,
      industry_id: 1,
      job_experience_id: 1
    })
      .then(response => {
        return response.json()
      })
      .then(data => {
        for (var index in data) {
          this.competencies.push({
            id: data[index].id,
            name: data[index].name,
            factors: data[index].factors_data,
            factor_names: data[index].factor_names
          })
          this.competencyNames.push(data[index].name)
        }  
      });
    }
  }
</script>