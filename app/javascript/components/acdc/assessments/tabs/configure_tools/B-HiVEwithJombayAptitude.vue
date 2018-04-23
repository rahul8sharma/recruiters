<template>
  <div class="edit_section">
    <div class="section_title uppercase fs-12 bold">
      2. B-HiVE with Jombay Aptitude
    </div>

    <div class="p-15">
      <div class="divider-2"></div>
      
      <div class="clearfix">
        <div class="fs-16 black-9 uppercase large-16 columns">Show Sectional Score</div>
        <div class="toggleSwitch large-14 columns">
          <label class="toggle">
            <input class="toggle-checkbox" type="checkbox"/>
            <div class="toggle-switch"></div>
            <span class="toggle-label">Don’t Show</span>
          </label>
        </div> 
      </div>
      
      <div class="divider-1"></div>
      
      <div class="select-box large-15">
        <div class="form-group">
          <model-select :options="options"
            v-model="item"
            placeholder="Select Aptitude Assessment">
          </model-select>
          <label>Select Aptitude Assessment</label>
        </div>
      </div>

      <em class="fs-12 black-6">(Access Code links the HireMe assessment to the Jombay Assessment)</em>
     
      <div class="divider-2"></div>

      <a href="#" class="more_actions_btn uppercase fs-12 bold open">
        More Actions
      </a>
      <em class="fs-12 black-6">(Tool weightage)</em>

      <div class="more_actions_container open">

        <div class="form-group large-15 column">
          <input type="text" placeholder="Tool Weightage">
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
    data () {
      return {
        options: [
          { value: '1', text: 'aa' + ' - ' + '1' },
          { value: '2', text: 'ab' + ' - ' + '2' },
          { value: '3', text: 'bc' + ' - ' + '3' },
          { value: '4', text: 'cd' + ' - ' + '4' },
          { value: '5', text: 'de' + ' - ' + '5' }
        ],
        item: {
          value: '',
          text: ''
        },
        searchText: '', // If value is falsy, reset searchText & searchItem
        items: [],
        lastSelectItem: {}
      }
    },
    methods: {
      onSelect (items, lastSelectItem) {
        this.items = items
        this.lastSelectItem = lastSelectItem
      },
      // deselect option
      reset () {
        this.items = [] // reset
      },
      // select option from parent component
      selectOption () {
        this.items = _.unionWith(this.items, [this.options[0]], _.isEqual)
      }
    },
    components: {
      MultiSelect, ModelSelect
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