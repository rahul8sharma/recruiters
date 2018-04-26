<template>
  <div v-if="field.active" class="clearfix">
    <div class="fs-14 black-9 line-height-4 bold large-7 columns">
      {{field.label}}
      <span v-if="field.is_mandatory" class="color-warning">*</span>
    </div>
    <div class="select-box large-12 columns">
      <div class="form-group">
        <model-select :options="options"
          v-model="item"
          v-bind:placeholder="field.placeholder">
        </model-select>
        <label>{{field.placeholder}}</label>
        <!-- TODO Need to set default_value -->
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
        options: [],
        item: {
          value: '',
          text: ''
        },
      }
    },
    components: { ModelSelect },
    mounted: function() {
      for (var  index = 0; index < this.field.options.length; index++) {
        this.options[index] = { value: index, text: this.field.options[index] };
      }
    }
  }
</script>