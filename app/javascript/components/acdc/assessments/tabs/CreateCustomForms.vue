<template>
  <div class="edit_section">
    <div class="select-box large-15">
      <div class="form-group">
        <model-select :options="existingForms"
          v-model="existingForm"
          placeholder="Select a form from existing">
        </model-select>
        <label>Select a form from existing</label>
      </div>
    </div>
    
    <div class="divider-1"></div>
    <div class="fs-16 black-9 line-height-2 pr-25 left">OR</div>
    <button class="button btn-warning uppercase fs-14 left">Create New Form</button>
    <div class="clr"></div> 

    <div class="divider-1"></div>
    <hr/>
    <div class="divider-1"></div>

    <div class="fs-16 black-9 left bold">Form Preview:</div>
    <button class="button btn-warning btn-link uppercase fs-16 right bold">Edit</button>
    <div class="clr"></div>
    
    <FormPreview v-if="showPreview" v-bind:definedFields="definedFields"></FormPreview>
    <!-- <CreatNewModel></CreatNewModel> -->
  </div>
</template>

<script>
  import FormPreview from 'components/acdc/assessments/tabs/custom_forms/FormPreview.vue'
  // import CreatNewModel from 'components/acdc/assessments/tabs/custom_forms/CreateNew.vue'
  import { ModelSelect } from 'vue-search-select'
 
  export default {
    props: ['tabData'],
    data () {
      return {
        existingForms: [],
        existingForm: {
          value: '',
          text: ''
        },
        showPreview: false,
        definedFields: []
      }
    },
    created: function() {
     this.get.defined_forms({company_id: 2})
      .then(response => {
        return response.json()
      })
      .then(data => {
        this.existingForms = data
      });
    },
    components: {
      ModelSelect, FormPreview
    },
    watch: {
      existingForm: function (form_object) {
        this.get.defined_field({company_id: 2, defined_form_id: form_object.value})
          .then(response => {
            return response.json()
          })
          .then(data => {
            this.definedFields = data
            this.showPreview = true
          });
        this.tabData.raw_data.default_form_id =  this.existingForm.value
      }
    }
  }
</script>

<style lang="sass" scoped>
  .field_list
    .field_list_item
      position: relative
      padding: 30px
      padding-left: 55px
      border-top: 1px solid  rgba(0, 0, 0, 0.1)
      .index
        position: absolute
        left: 25px
        top: 55px
        font-weight: 600
        color: rgba(0, 0, 0, 0.9)
      .shuffle_actions
        .shuffle_action
          cursor: pointer
          float: left
          font-weight: 600
          color: rgba(0, 0, 0, 0.54)
          &:first-child
            margin-right: 35px
          &:hover
            opacity: 0.6
          &.disabled
            color: rgba(0, 0, 0, 0.24)
            cursor: not-allowed
            &:hover
              color: rgba(0, 0, 0, 0.24)
              opacity: 1    

</style>