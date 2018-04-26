<template>
  <div v-if="field.active" class="clearfix">
    <div class="divider-1"></div>
    <div class="fs-14 black-9 line-height-2 bold large-7 columns">
      {{field.label}} 
      <span v-if="field.is_mandatory" class="color-warning">*</span>
    </div>
    <div class="large-12 columns">
      <textarea data-gramm_editor="false" v-bind:placeholder="field.placeholder"></textarea>
    </div>
    <div class="clr"></div>
    <div class="divider-1"></div>
  </div>
</template>
<script>
  export default {
    props: ['field']
  }
</script>