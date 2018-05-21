<template>
  <div>
    <div class="section_heading flex-box">
      <span>Custom Forms</span>
      <div class="spacer"></div>
      <a v-if="!isSendForReview" class="button btn-warning btn-link" @click="changeCurrentTab">
        Edit
      </a>
    </div>
    <div class="content_body fs-14">
      <div class="p-8">
        <FormPreview v-bind:definedFields="definedFields"></FormPreview>
      </div>

    </div>
  </div>
</template>

<style lang="sass" scoped>
  @import '~assets/css/jit_review'
</style>
<script>
import FormPreview from 'components/acdc/assessments/tabs/custom_forms/FormPreview.vue'

  export default {
    props: ['createCustomForms', 'isSendForReview'],
    components: { FormPreview },
    data () {
      return {
        definedFields: []
      }
    },
    methods: {
      changeCurrentTab() {
        this.$store.dispatch('setChangeCurrentTab', {
          currentTab: {text: 'Create Custom Forms', index: 2}
        })
      }
    },
    created: function() {
      let definedFormId = this.createCustomForms.defined_form_id.value
      if(definedFormId!= null && definedFormId.length != 0) {
        this.get.defined_field({
          company_id: this.$store.state.AcdcStore.companyId,
          defined_form_id: this.createCustomForms.defined_form_id.value
        }).then(response => {
          return response.json()
        }).then(data => {
          this.definedFields = data
        });
      } else {
        this.definedFields = this.createCustomForms.defined_form.defined_fields_attributes
      }
    }
  }
</script>