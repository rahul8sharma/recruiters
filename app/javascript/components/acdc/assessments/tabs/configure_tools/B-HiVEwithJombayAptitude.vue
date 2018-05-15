<template>
  <div>
    <div class="section_title uppercase fs-12 bold">
      {{index}}. B-HiVE with Jombay Aptitude
    </div>

    <div class="p-15">
      <div class="divider-2"></div>
      
      <div class="clearfix">
        <div class="fs-16 black-9 uppercase large-16 columns">Show Sectional Score</div>
        <div class="toggleSwitch large-14 columns">
          <label class="toggle">
            <input v-model="configureToolData.is_sectional_score" class="toggle-checkbox" type="checkbox"/>
            <div class="toggle-switch"></div>
            <span class="toggle-label">{{configureToolData.is_sectional_score ? 'Show' : "Don’t Show"}}</span>
          </label>
        </div> 
      </div>
      
      <div class="divider-1"></div>
      
      <div class="select-box large-15">
        <div class="form-group">
          <model-select :options="options"
            placeholder="Select Aptitude Assessment"
            v-model="configureToolData.aptitude_assessment"
          >
          </model-select>
          <label>Select Aptitude Assessment</label>
        </div>
      </div>

      <em class="fs-12 black-6">(Access Code links the HireMe assessment to the Jombay Assessment)</em>
     
      <div class="divider-2"></div>

      <a class="more_actions_btn uppercase fs-12 bold" v-bind:class="[moreActions ? 'open' : 'close']" @click="moreActions = !moreActions">
        More Actions
      </a>
      <em class="fs-12 black-6">(Tool weightage)</em>

      <div class="more_actions_container" v-bind:class="{'open':moreActions}">

        <div class="form-group large-15 column">
          <input v-model="configureToolData.tool_weightage" type="text" placeholder="Tool Weightage">
          <label>Tool Weightage</label>
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
        options: [],
        moreActions: false
      }
    },
    components: {
      MultiSelect, ModelSelect
    },
    created: function() {
      for (let index=1; index <= 5; index++) {
        this.options.push({value: index, text: 'a' + index})
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
    margin-right: 16px
    &.open
      background: url('~assets/images/ic-dropdown-warning.svg') no-repeat right center 
  .more_actions_container
    overflow: hidden
    display: none
    padding-top: 15px
    &.open
      display: block
</style>