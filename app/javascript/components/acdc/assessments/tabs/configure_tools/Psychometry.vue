<template>
  <div>
    <div class="section_title uppercase fs-12 bold">
      {{index}}. Psychometry
    </div>

    <div class="p-15">

      <div class="large-12 pt-12">
        <em class="fs-12 black-6">(lorem ipsum text for psychometry help item for better understanding of the candidate. Helptext is in Hinglish Language)</em>
      </div>

      <div class="divider-1"></div>

      <div class="clearfix">
        <div class="fs-16 black-9 large-8 columns">
          Select Psychometry Type
          <span class="color-warning">*</span>
        </div>
        <div class="large-6 columns">
          <label class="custom-radio">
            <input type="radio" name="PsychometryType" value="employee" v-model="configureToolData.candidate_stage" />
            <div class="label-text">Development</div>
          </label>
        </div>
        <div class="large-6 columns">
          <label class="custom-radio">
            <input type="radio" name="PsychometryType" value="candidate" v-model="configureToolData.candidate_stage" />
            <div class="label-text">Hiring</div>
          </label>
        </div>
      </div>
      
      <div class="divider-2"></div>

      <div class="clearfix">
        <div class="fs-16 black-9 large-8 columns">
          Select Assessment Class
          <span class="color-warning">*</span>
        </div>
        <div class="large-6 columns">
          <label class="custom-radio">
            <input type="radio" name="AssessmentClass" value="competency" v-model="configureToolData.assessment_type" />
            <div class="label-text">Competency</div>
          </label>
        </div>
        <div class="large-6 columns">
          <label class="custom-radio">
            <input type="radio" name="AssessmentClass" value="fit" v-model="configureToolData.assessment_type"/>
            <div class="label-text">Trait</div>
          </label>
        </div>
      </div>

      <div class="divider-2"></div>
      <div class="select-box large-15">
        <div class="form-group">
          <multi-select :options="languages"
            :selected-options="configureToolData.languages"
            placeholder="Select Language for the assessment*"
            @select="onSelect">
          </multi-select>
          <label>Select Language for the assessment*</label>
        </div>
        <em class="fs-12 black-6 pt-8">(You can select multiple languages as well)</em>
        
        <div class="divider-1"></div>  

        <div class="form-group">
          <model-select :options="pageSize"
            v-model="configureToolData.page_size"
            placeholder="Select Page Size*">
          </model-select>
          <label>Select Page Size*</label>
        </div>
      </div>
      <em class="fs-12 black-6 pt-8">(*How Many questions will appear on one page)</em>

      <div class="divider-2"></div>
      <div class="large-30">
        <a class="more_actions_btn uppercase fs-12 bold" v-bind:class="[moreActions ? 'open' : 'close']" @click="moreActions = !moreActions">
          More Actions
        </a>
        <em class="fs-12 black-6 pl-20">(Applicant ID, Help Text, Tool weightage)</em>

        <div class="more_actions_container" v-bind:class="[moreActions ? 'show' : 'hide']"">

          <div class="clearfix">
            <div class="large-15 columns">
              <div class="fs-16 black-9 uppercase">Enable Applicant ID</div>
              <em class="fs-12 pt-10 black-6">(Applicant ID is 8 digit number which can act as Employee code)</em>
            </div>

            <div class="large-15 columns">
              <div class="toggleSwitch large-14 columns">
                <label class="toggle">
                  <input class="toggle-checkbox" type="checkbox" v-model="configureToolData.set_applicant_id">
                  <div class="toggle-switch"></div>
                  <span class="toggle-label">{{configureToolData.set_applicant_id ? 'Enabled' : 'Disabled'}}</span>
                </label>
              </div> 
            </div>

          </div>
          
          <div class="divider-2"></div>

          <div class="clearfix">
            <div class="large-15 columns">
              <div class="fs-16 black-9 uppercase">Show Help text for Items</div>
              <em class="fs-12 pt-10 black-6">(If enabled, system will show help text for every item for better understanding of the candidate. Helptext is in Hinglish Language)</em>
            </div>

            <div class="large-15 columns">
              <div class="toggleSwitch large-14 columns">
                <label class="toggle">
                  <input class="toggle-checkbox" type="checkbox" v-model='configureToolData.show_help_text'>
                  <div class="toggle-switch"></div>
                  <span class="toggle-label">{{configureToolData.show_help_text ? 'Show' : "Don't Show"}}</span>
                </label>
              </div> 
            </div>

          </div>
          
          <div class="divider-2"></div>
          <div class="fs-16 black-9 uppercase">Report Upload Callbacks</div>
          <div class="divider-1"></div>
          <div class="clearfix">
            <div class="large-5 columns">
              <label class="custom-checkbox">
                <input type="checkbox" value="Talview" v-model='configureToolData.report_upload_callbacks' />
                <div class="label-text">Talview</div>
              </label>            
            </div>

            <div class="large-5 columns">
              <label class="custom-checkbox">
                <input type="checkbox" value="Taleo" v-model='configureToolData.report_upload_callbacks' />
                <div class="label-text">Taleo</div>
              </label>            
            </div>

            <div class="large-5 columns">
              <label class="custom-checkbox">
                <input type="checkbox" value="Success Factor" v-model='configureToolData.report_upload_callbacks' />
                <div class="label-text">Success Factor</div>
              </label>            
            </div>

            <div class="large-5 columns">
              <label class="custom-checkbox">
                <input type="checkbox" value="Zoho" v-model='configureToolData.report_upload_callbacks' />
                <div class="label-text">Zoho</div>
              </label>            
            </div>
            
          </div>

          <div class="divider-2"></div>

          <div class="form-group large-15 column">
            <input type="text" placeholder="Tool Weightage" v-model='configureToolData.tool_weightage'>
            <label>Tool Weightage</label>
          </div>

        </div>
        
      </div>
    </div>

  <div class="divider-3"></div>
  </div>
</template>

<script>
  import _ from 'lodash'
  import { MultiSelect } from 'vue-search-select'
  import { ModelSelect } from 'vue-search-select'
 
  export default {
    props: ['configureToolData', 'index'],
    data () {
      return {
        languages: [],
        pageSize: [],
        moreActions: false
      }
    },
    methods: {
      onSelect (items, lastSelectItem) {
        this.configureToolData.languages = []
        this.configureToolData.languages = items
      }
    },
    components: {
      MultiSelect, ModelSelect
    },
    created: function() {
      this.get.languages({company_id: 2})
        .then(response => {
          return response.json()
        })
        .then(data => {
          this.languages = data.languages
        })
        for (let index=1; index <= 100; index++) {
          this.pageSize.push({value: index, text: index})
        }
    }
  }
</script> 
<style lang="sass" scoped>
  $color-warning: #ff8308 
  @mixin flex
    display: -webkit-box
    display: -moz-box
    display: -ms-flexbox
    display: -webkit-flex
    display: flex
  .section_title
    color: $color-warning
    padding: 8px
    background: #fff4e9
  .more_actions_btn
    padding-right: 15px
    background: url('~assets/images/ic-dropright-warning.svg') no-repeat right center
    &.open
      background: url('~assets/images/ic-dropdown-warning.svg') no-repeat right center 
  .more_actions_container
    overflow: hidden
    display: none
    padding-top: 30px
    &.open
      display: block

</style>