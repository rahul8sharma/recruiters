<template>
  <div class="modal scrollable modalOpen">
    <div class="modal-container large-20">
      <div class="heading fs-14 uppercase">
        <span>Create / Edit Custom Form</span>
        <div class="spacer"></div>
        <div @click="model.createNewShow=false" class="close">&times;</div>
      </div>

      <div class="modal-body p-0">
        <div class="create_new_form">
          <form>
            <div class="p-30">
              <div class="form-group large-15 column">
                <input type="text" v-model="defined_form.name" placeholder="Name of the form:" />
                <label>Name of the form:</label>
              </div>

              <div class="large-15 column fs-14 black-6">
                <div class="divider-1"></div>
                11/24 characters
              </div>

              <div class="clr"></div>
              <em class="fs-12 black-6">(*The Name of the form appears on the Report and Dashboard)</em>
            </div>

            <ul class="field_list">
              <li v-for="(definedField, index) in defined_form.defined_fields_attributes" class="field_list_item">
                <div class="index">1.</div>

                <div class="clearfix">
                  <div class="select-box large-7 columns">
                    <div class="form-group">
                      <v-select class="field_list" :options="options" 
                        v-model="definedField.field_type"
                        placeholder="Type">
                      </v-select>
                      <label>Type</label>
                    </div>
                  </div>

                  <div class="large-3 columns"></div>
                  <div class="form-group large-7 columns">
                    <input type="text" v-model="definedField.identifier" placeholder="Identifier" />
                    <label>Identifier</label>
                  </div>

                  <div class="shuffle_actions right">
                    <a :disabled="index == (defined_form.defined_fields_attributes.length - 1)" @click.prevent="moveDown(index)" class="shuffle_action ">Move Down</a>
                    <a :disabled="index == 0" @click.prevent="moveUp(index)" class="shuffle_action">Move Up</a>

                    <button @click.prevent="removeField(index)" class="button btn-default btn-link uppercase fs-40 black-10 large-3 columns">&times;</button>

                    <div class="clr"></div>
                  </div>
                  <div class="clr"></div>
                </div>

                <div class="divider-1"></div>

                <div class="clearfix">
                  <div class="form-group large-7 columns">
                    <input v-model="definedField.label" type="text" placeholder="Label" />
                    <label>Label</label>
                  </div>

                  <div class="large-2 columns"></div>

                  <div class="form-group large-12 columns">
                    <input v-model="definedField.placeholder" type="text" placeholder="Placeholder" />
                    <label>Placeholder</label>
                  </div>

                  <div class="large-2 columns"></div>

                  <div class="form-group large-7 columns">
                    <input v-model="definedField.default_value" type="text" placeholder="Default Value" />
                    <label>Default Value</label>
                  </div>

                  <div class="clr"></div>
                </div>

                <div class="divider-1"></div>
                
                <div class="clearfix">
                  <div class="form-group large-18">
                    <input v-model="definedField.validator_regex" type="text" placeholder="Validator Regex" />
                    <label>Validator Regex</label>
                  </div>
                </div>

                <div class="divider-1"></div>
                
                <div class="clearfix flex-box">
                  <div class="toggleSwitch">
                    <label class="toggle">
                      <input v-model="definedField.active" class="toggle-checkbox" type="checkbox">
                      <div class="toggle-switch"></div>
                      <span class="toggle-label">Active</span>
                    </label>
                  </div> 
                  <div class="large-2"></div>
                  <label class="custom-checkbox">
                    <input v-model="definedField.is_mandatory" type="checkbox"/>
                    <div class="label-text">Mandatory</div>
                  </label>    
                </div>

                <div class="divider-1"></div>
                <div class="large-20">
                  <textarea v-model="definedField.options" class="bg-black-1" data-gramm_editor="false" placeholder="Type here something abpout your interest"></textarea>
                </div>

              </li>
            </ul>
          </form>
        </div>

        <div class="actions">
          <button @click.prevent="addDefinedField()" class="button btn-warning btn-link  uppercase fs-14">+ Add More Field</button>
          <div class="spacer"></div>
          <button @click="saveInTabData()" class="button btn-warning uppercase fs-14">Save</button>
        </div>
      </div>
    </div>
  </div>
</template>
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
<script>
  // import { ModelSelect } from 'vue-search-select'
  import VSelect from 'vue-select'
  
  export default {
    props: ['previewForm', 'tabData', 'model'],
    data () {
      return {
        options: [
          "TextField", "DropDown", "CheckBox", 
          "TextArea", "RadioButton"
        ],
        defined_form: {
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
            is_mandatory: '',
            placeholder: '',
            options: '',
            field_order: 0
          }]   
        }
      }
    },
    components: {
      'v-select': VSelect
    },
    methods: {
      moveUp(index) {
        let temp = this.defined_form.defined_fields_attributes[index].field_order = (this.defined_form.defined_fields_attributes[index].field_order - 1 )
        this.defined_form.defined_fields_attributes[temp].field_order = (this.defined_form.defined_fields_attributes[temp].field_order + 1)

        this.defined_form.defined_fields_attributes.sort(function(a, b){
        return a.field_order - b.field_order });
      },
      moveDown(index) {
        let temp = this.defined_form.defined_fields_attributes[index].field_order = (this.defined_form.defined_fields_attributes[index].field_order + 1 )
        this.defined_form.defined_fields_attributes[temp].field_order = (this.defined_form.defined_fields_attributes[temp].field_order - 1)

        this.defined_form.defined_fields_attributes.sort(function(a, b){
        return a.field_order - b.field_order });
      },
      addDefinedField(){
        this.defined_form.defined_fields_attributes.push({
          field_type: '',    
          label: '',
          defined_form_id: '',
          active: false,  
          identifier: '',
          validator_regex: '',
          default_value: '',
          is_mandatory: '',
          placeholder: '',
          options: '',
          field_order: this.defined_form.defined_fields_attributes.length
        })
      },
      removeField(index) {
        this.defined_form.defined_fields_attributes.splice(index, 1)
      },
      saveInTabData(){
        this.tabData.defined_form = this.defined_form
        this.previewForm.definedFields = this.defined_form.defined_fields_attributes
        this.previewForm.showPreview = true
        this.model.createNewShow=false
      }
    },
    create: function() {
      this.defined_form = this.tabData.defined_form
    }
  }
</script>