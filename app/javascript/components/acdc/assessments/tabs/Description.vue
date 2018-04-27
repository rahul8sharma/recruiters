<template>
  <div class="edit_section">
    <form>
      <div class="form-group large-15 column">
        <input type="text" placeholder="Name of Assessment" v-model="tabData.name" />
        <label>Name of Assessment</label>
      </div>

      <div class="large-15 column fs-14 black-6">
        <div class="divider-1"></div>
        11/20 characters
      </div>

      <div class="clr"></div>

      <em class="fs-12 black-6">(*The Name of the Assessment appears on the Report and Dashboard)</em>
      <div class="divider-1"></div>
      <div class="select-box large-15">
        <div class="form-group">
          <model-select :options="industries"
            v-model="selectIndustry"
            placeholder="Select Industry">
          </model-select>
          <label>Select Industry</label>
        </div>
        
        <div class="divider-1"></div>

        <div class="form-group">
          <model-select :options="functionalAreas"
            v-model="selectFunctionArea"
            placeholder="Select Functional Area">
          </model-select>
          <label>Select Functional Area</label>
        </div>
        
        <div class="divider-1"></div>

        <div class="form-group">
          <model-select :options="jobExperiences"
            v-model="selectJobExperiences"
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
            <span class="toggle-label" v-show="!tabData.raw_data.enable_proctoring">Disabled</span>
            <span class="toggle-label" v-show="tabData.raw_data.enable_proctoring">Enabled</span>
          </label>
        </div> 
      </div>
    </form>

    <div class="divider-2"></div>

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
        selectFunctionArea: {value: '', text: ''},
        selectIndustry: {value: '', text: ''},
        selectJobExperiences: {value: '', text: ''}
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
          this.selectIndustry = this.tabData.raw_data.industry_id
          this.selectFunctionArea = this.tabData.raw_data.functional_area_id
          this.selectJobExperiences = this.tabData.raw_data.job_experience_id
        })
    },
    watch: {
      selectIndustry: function (val) {
        this.tabData.raw_data.industry_id = this.selectIndustry
      },
      selectFunctionArea: function (val) {
          this.tabData.raw_data.functional_area_id = this.selectFunctionArea
      },
      selectJobExperiences: function (val) {
          this.tabData.raw_data.job_experience_id = this.selectJobExperiences
      }
    }
  }
</script>