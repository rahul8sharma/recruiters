<template>
  <div v-if="field.active" class="clearfix">
    <div class="fs-14 black-9 line-height-4 bold large-7 columns">
      {{field.label}}
      <span v-if="field.is_mandatory" class="color-warning">*</span>
    </div>
    <div class="select-box large-12 columns">
      <div class="form-group">
        <v-select :options="field.options"
          v-model="field.default_value"
          v-bind:placeholder="field.placeholder">
        </v-select>
        <label>{{field.placeholder}}</label>
      </div>
    </div>
  </div>
</template>
<script>
  import VSelect from 'vue-select'
  export default {
    props: ['field'],
    data() {
      return {
        item: ''
      }
    },
    components: { 'v-select': VSelect },
  }
</script>