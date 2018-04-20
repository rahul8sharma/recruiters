<template>
  <div class="edit_section">
    <form>
      <div class="form-group large-15 column">
        <input type="text" placeholder="New Jombay Aptitude" />
        <label>New Jombay Aptitude</label>
      </div>

      <div class="large-15 column fs-14 black-6">
        <div class="divider-1"></div>
        11/24 characters
      </div>

      <div class="clr"></div>

      <em class="fs-12 black-6">(*The Name of the Assessment appears on the Report and Dashboard)</em>
      <div class="divider-1"></div>
      <div class="select-box large-15">
        <div class="form-group">
          <model-select :options="options"
            v-model="item"
            placeholder="Select Industry">
          </model-select>
          <label>Select Industry</label>
        </div>
        
        <div class="divider-1"></div>

        <div class="form-group">
          <model-select :options="options"
            v-model="item"
            placeholder="Select Functional Area">
          </model-select>
          <label>Select Functional Area</label>
        </div>
        
        <div class="divider-1"></div>

        <div class="form-group">
          <model-select :options="options"
            v-model="item"
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
            <input class="toggle-checkbox" type="checkbox">
            <div class="toggle-switch"></div>
            <span class="toggle-label">Disabled</span>
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
        options2: [
          { value: '1', text: 'aa' + ' - ' + '1' },
          { value: '2', text: 'ab' + ' - ' + '2' },
          { value: '3', text: 'bc' + ' - ' + '3' },
          { value: '4', text: 'cd' + ' - ' + '4' },
          { value: '5', text: 'de' + ' - ' + '5' }
        ],
        item2: ''
      }
    },
    methods: {
      reset () {
        this.item = {}
      },
      selectOption () {
        // select option from parent component
        this.item = this.options[0]
      },
      reset2 () {
        this.item2 = ''
      },
      selectOption2 () {
        // select option from parent component
        this.item2 = this.options2[0].value
      }
    },
    components: {
      ModelSelect
      // https://www.npmjs.com/package/vue-search-select
    }
  }
</script>