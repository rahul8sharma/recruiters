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
     
      <button class="button btn-warning uppercase fs-14">
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
              <span class="toggle-label" v-if="!tabData.raw_data.enable_proctoring">Disabled</span>
              <span class="toggle-label" v-if="tabData.raw_data.enable_proctoring">Enabled</span>
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
        selectFunctionArea: {value: '', text: ''},
        selectIndustry: {value: '', text: ''},
        selectJobExperiences: {value: '', text: ''},
        nameMaxLength: 20
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
          this.selectIndustry = {value: this.tabData.raw_data.industry_id, text: ''}
          this.selectFunctionArea = {value: this.tabData.raw_data.functional_area_id, text: ''}
          this.selectJobExperiences = {value: this.tabData.raw_data.job_experience_id, text: ''}
        })
    },
    watch: {
      selectIndustry: function (val) {
        this.tabData.raw_data.industry_id = this.selectIndustry.value
      },
      selectFunctionArea: function (val) {
          this.tabData.raw_data.functional_area_id = this.selectFunctionArea.value
      },
      selectJobExperiences: function (val) {
          this.tabData.raw_data.job_experience_id = this.selectJobExperiences.value
      }
    }
  }
</script>