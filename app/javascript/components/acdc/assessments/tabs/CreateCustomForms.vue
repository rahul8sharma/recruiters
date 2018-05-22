<template>
  <div>
    <div class="action_bar">
      <div class="fs-16 black-9 bold">Create Custom Form</div>

      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            This step allows you to select a custom form which will appear at the start of the assessment. You can add/remove fields from existing form or add new form altogether.
          </div>
        </div>
      </div>
     
      <button 
        class="button btn-warning uppercase fs-14" 
        @click="saveAndNext"
        :disabled = "isSaveNextButtonDisabled"
      >
        Save &amp; Next
      </button>
    </div>
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
      <div class="large-30">
        <div class="fs-16 black-9 line-height-2 pr-25 left">OR</div>
        <button  @click="createNewForm()" class="button btn-warning uppercase fs-14 left">Create New Form</button>
        <div class="clr"></div> 
        
      </div>

    <div class="divider-1"></div>
    <hr/>
    <div class="divider-1"></div>

    <div class="fs-16 black-9 left bold">Form Preview:</div>
    <em v-if="isFormNewOrEdit" class="fs-12 black-6">&ensp;(changes saved for {{tabData.raw_data.defined_form.name}})</em>
    
    <button v-if="previewForm.showPreview" @click="editForm()" class="button btn-warning btn-link uppercase fs-16 right bold">Edit</button>
    <div class="clr"></div>
    
    <FormPreview v-if="previewForm.showPreview" v-bind:definedFields="previewForm.definedFields"></FormPreview>
    <CreatNewModel v-if="model.createNewShow"
      v-bind:previewForm="previewForm"
      v-bind:tabData="tabData.raw_data"
      v-bind:definedForm="definedForm"
      v-bind:model="model"
    ></CreatNewModel>
    <div class="divider-4"></div>
  </div>
 </div> 
</template>

<script>
  import FormPreview from 'components/acdc/assessments/tabs/custom_forms/FormPreview.vue'
  import CreatNewModel from 'components/acdc/assessments/tabs/custom_forms/CreateNew.vue'
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
        previewForm: {
          showPreview: false,
          definedFields: [], 
        },
        model: {
          createNewShow: false
        },
        definedForm: {
          name: '',
          active: true,
          parent_id: '',
          defined_fields_attributes: [{
            field_type: '',
            label: '',
            defined_form_id: '',
            active: false,
            identifier: '',
            validator_regex: '',
            default_value: '',
            is_mandatory: false,
            placeholder: '',
            options: '',
            field_order: 0
          }]
        },
        isSaveNextButtonDisabled: true
      }
    },
    created: function() {
     this.get.defined_forms({company_id: this.$store.state.AcdcStore.companyId})
      .then(response => {
        return response.json()
      })
      .then(data => {
        this.existingForms = data
        if(this.tabData.raw_data.defined_form_id != undefined && this.tabData.raw_data.defined_form_id.value != null && this.tabData.raw_data.defined_form_id.value.length !== 0) {
         this.existingForm = this.tabData.raw_data.defined_form_id
         this.tabData.raw_data.defined_form = {}
        }
        if(this.tabData.raw_data.defined_form_id != undefined && Object.keys(this.tabData.raw_data.defined_form).length !== 0) {
         this.existingForm = { value: '', text: '' }
         this.previewForm.definedFields = this.tabData.raw_data.defined_form.defined_fields_attributes
         this.previewForm.showPreview = true
        }
      });
    },
    components: {
      ModelSelect, FormPreview, CreatNewModel
    },
    methods: {
      createNewForm() {
        if(Object.keys(this.tabData.raw_data.defined_form).length !== 0) { 
          console.log("Template Data create New")
          // dialog box come here
          this.tabData.raw_data.defined_form = {}
          this.model.createNewShow=true
          this.definedForm = {
            name: '',
            active: true,
            parent_id: '',
            defined_fields_attributes: [{
              field_type: '',
              label: '',
              defined_form_id: '',
              active: false,
              identifier: '',
              validator_regex: '',
              default_value: '',
              is_mandatory: false,
              placeholder: '',
              options: '',
              field_order: 0
            }]
          }
         } else { 
          this.tabData.raw_data.defined_form = {}
          this.model.createNewShow=true
          this.definedForm = {
            name: '',
            active: true,
            parent_id: '',
            defined_fields_attributes: [{
              field_type: '',
              label: '',
              defined_form_id: '',
              active: false,
              identifier: '',
              validator_regex: '',
              default_value: '',
              is_mandatory: false,
              placeholder: '',
              options: '',
              field_order: 0
            }]
          }
        }
      },
      editForm() {
        this.definedForm.defined_fields_attributes = JSON.parse(JSON.stringify(this.previewForm.definedFields));
        this.definedForm.parent_id = this.existingForm
        this.model.createNewShow=true
      },
      saveAndNext() {
        this.$store.dispatch('updateAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          acdc_assessment: {create_custom_forms: this.tabData.raw_data}
        })
      }
    },
    watch: {
      existingForm: function (form_object) {
        if(form_object.value != '') {
          this.get.defined_field({company_id: this.$store.state.AcdcStore.companyId, defined_form_id: form_object.value})
            .then(response => {
              return response.json()
            })
            .then(data => {
              this.previewForm.definedFields = data
              this.previewForm.showPreview = true
            });
          this.tabData.raw_data.defined_form_id =  this.existingForm
          this.tabData.raw_data.defined_form = []
        }
      },
      "previewForm.definedFields": function() {
        if(this.tabData.raw_data.defined_form.defined_fields_attributes != undefined && this.tabData.raw_data.defined_form.defined_fields_attributes.length != 0) {
          this.existingForm= {value: '', text: ''}
        }
      },
      tabData: {
         handler(val){
           if(Object.keys(this.tabData.raw_data).length !== 0) {
            let definedFormId = this.tabData.raw_data.defined_form_id.value
            this.isSaveNextButtonDisabled = (definedFormId == null || definedFormId.length == 0)
            && (this.tabData.raw_data.defined_form == null || Object.keys(this.tabData.raw_data.defined_form).length == 0)
          }
         },
         deep: true
      }
    },
    computed: {
      isFormNewOrEdit: function () {
        return (this.tabData[this.createTemplateName] != undefined && (Object.keys(tabData.raw_data.defined_form).length !== 0))
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