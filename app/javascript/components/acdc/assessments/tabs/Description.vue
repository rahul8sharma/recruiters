<template>
  <div>
    <div class="action_bar">
      <div class="fs-16 black-9 bold">Add more details for this Assessment</div>

      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos necessitatibus, facilis dolorum, impedit fugit voluptatibus nemo unde ut a dolore vero quo sint perspiciatis. Exercitationem saepe cum a vitae! Eligendi.
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
      <form>
        <div class="form-group large-15 column">
          <input type="text" placeholder="Name of Assessment" v-model="tabData.name" :maxlength="nameMaxLength" />
          <label>Name of Assessment</label>
        </div>

        <div class="large-15 column fs-14 black-6">
          <div class="divider-1"></div>
          {{nameMaxLength - tabData.name.length}}/{{nameMaxLength}} characters
        </div>

        <div class="clr"></div>

        <em class="large-15 fs-12 black-6">(*The Name of the Assessment appears on the Report and Dashboard)</em>
        <div class="divider-1"></div>
        <div class="select-box large-15">
          <div class="form-group">
            <model-select :options="industries"
              v-model="tabData.raw_data.industry_id"
              placeholder="Select Industry">
            </model-select>
            <label>Select Industry</label>
          </div>
          
          <div class="divider-1"></div>

          <div class="form-group">
            <model-select :options="functionalAreas"
              v-model="tabData.raw_data.functional_area_id"
              placeholder="Select Functional Area">
            </model-select>
            <label>Select Functional Area</label>
          </div>
          
          <div class="divider-1"></div>

          <div class="form-group">
            <model-select :options="jobExperiences"
              v-model="tabData.raw_data.job_experience_id"
              placeholder="Select Experience">
            </model-select>
            <label>Select Experience</label>
          </div>
          
        </div>

        <div class="divider-2"></div>

        <div class="clearfix">
          <div class="fs-16 black-9 uppercase large-16 columns">Enable Proctoring </div>
          <div class="toggleSwitch large-14 columns">
            <label class="toggle">
              <input class="toggle-checkbox" type="checkbox" v-model="tabData.raw_data.enable_proctoring">
              <div class="toggle-switch"></div>
              <span class="toggle-label">{{tabData.raw_data.enable_proctoring ? 'Enabled' : 'Disabled'}}</span>
            </label>
          </div> 
        </div>
      </form>

      <div class="divider-4"></div>

    </div>
  </div>
</template>
<script>
  import { ModelSelect } from 'vue-search-select'
 
  export default {
    props: ['tabData'],
    data () {
      return {
        functionalAreas: [],
        industries: [],
        jobExperiences: [],
        nameMaxLength: 20,
        isSaveNextButtonDisabled: true
      }
    },
    components: {
      ModelSelect
      // https://www.npmjs.com/package/vue-search-select
    },
    created: function() {
      this.get.meta_data({company_id: 2})
        .then(response => {
          return response.json()
        })
        .then(data => {
          this.functionalAreas = data.functional_areas
          this.industries = data.industries
          this.jobExperiences = data.job_experiences
        })
    },
    methods: {
      saveAndNext() {
        this.$store.dispatch('updateAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          acdc_assessment: {description: this.tabData.raw_data, name: this.tabData.name}
        })
      }
    },
    watch: {
      tabData: {
         handler(val){
           if(Object.keys(this.tabData.raw_data).length !== 0) {
            this.isSaveNextButtonDisabled = this.tabData.name.length == 0 || this.tabData.raw_data.industry_id.value == '' || this.tabData.raw_data.industry_id.value == null
          }
         },
         deep: true
      }
    }
  }
</script>