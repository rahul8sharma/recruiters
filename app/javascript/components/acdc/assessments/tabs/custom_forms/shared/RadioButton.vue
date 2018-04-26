<template>
  <div v-if="field.active" class="clearfix">
    <div class="divider-1"></div>
    <div class="fs-14 black-9 bold large-7 columns">
      {{field.label}}
      <span v-if="field.is_mandatory" class="color-warning">*</span>
    </div>
    <div class="large-12 columns">
      <div v-for="(radio_name, radio_index) in field.options" class="large-10 columns">
        <label v-bind:key="radio_index" class="custom-radio">
          <input type="radio" name="gender"/>
          <div class="label-text">{{radio_name}}</div>
        </label>
      </div>  
      <div class="clr"></div>
      <div class="divider-1"></div>
    </div>
  </div>
</template>
<script>
  export default {
    props: ['field']
  }
</script>