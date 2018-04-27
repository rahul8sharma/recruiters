<template>
  <div class="form_preview">
    <template v-for="(form, index) in definedFields">
      <component :is="form.field_type" :key="index" v-bind:field="form"></component>
    </template>
  </div>
</template>

<script>
  import CheckBox from 'components/acdc/assessments/tabs/custom_forms/shared/CheckBox.vue'
  import TextField from 'components/acdc/assessments/tabs/custom_forms/shared/TextField.vue'
  import DropDown from 'components/acdc/assessments/tabs/custom_forms/shared/DropDown.vue'
  import TextArea from 'components/acdc/assessments/tabs/custom_forms/shared/TextAera.vue'
  import RadioButton from 'components/acdc/assessments/tabs/custom_forms/shared/RadioButton.vue'

  export default {
    props: ['definedFields'],
    components: {
      TextField, DropDown, CheckBox,
      TextArea, RadioButton
    }
  }
</script>

<style lang="sass" scoped>
  .form_preview
    border-radius: 2px
    background-color: #f6f6f6
    padding: 30px 16px
</style>