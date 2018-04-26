<template>
  <div v-if="field.active" class="clearfix">
    <div class="fs-14 black-9 line-height-3 bold large-7 columns">
      {{field.label}}
      <span v-if="field.is_mandatory" class="color-warning">*</span>
    </div>
    <div class="form-group large-12 columns">
      <input type="text" v-bind:value="field.default_value" v-bind:placeholder="field.placeholder" />
      <label>{{field.placeholder}}</label>
    </div>
  </div>
</template>
<script>
  export default {
    props: ['field']
  }
</script>