<template>
  <div v-if="field.active" class="clearfix">
    <div class="fs-14 black-9 line-height-4 bold large-7 columns">
      {{field.label}}
      <span v-if="field.is_mandatory" class="color-warning">*</span>
    </div>
    <div class="select-box large-12 columns">
      <div class="form-group">
        <model-select :options="format(field.options, field.default_value)"
          v-model="item"
          v-bind:placeholder="field.placeholder">
        </model-select>
        <label>{{field.placeholder}}</label>
      </div>
    </div>
  </div>
</template>
<script>
  import { ModelSelect } from 'vue-search-select'
  export default {
    props: ['field'],
    data() {
      return {
        item: { value: '', text: '' },
        formatData: []
      }
    },
    components: { ModelSelect },
    methods: {
      format(options, default_value) {
        if(this.formatData.length != options.length) {
          this.formatData = [] 
          for(var index= 0; index < options.length; index++ ) {
            this.formatData.push({value: options[index], text: options[index]})
          }
          this.item = { value: default_value, text: default_value }
        }
        return this.formatData
      }
    }
  }
</script>