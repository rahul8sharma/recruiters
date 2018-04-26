<template>
  <div v-if="field.active" class="clearfix">
    <div class="divider-1"></div>
    <div class="fs-14 black-9 bold large-7 columns">
      {{field.label}}
      <span v-if="field.is_mandatory" class="color-warning">*</span>
    </div>
    <div class="large-12 columns">
      <div v-for="" class="large-10 columns">
        <label class="custom-checkbox">
          <input v-bind:placeholder="field.placeholder" type="checkbox"/>
          <div class="label-text">{{field.placeholder}}</div>
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
