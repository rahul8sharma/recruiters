<template>
  <div>
    <div class="p-20">
      <div class="divider-1"></div>
      <div class="flex-box">
        <div>
          <div v-if="templateName == 'invitation_template_id'" class="fs-16 black-9 bold">Invitation Template</div>
          <div v-else-if="templateName == 'assessment_completion_notification_template_id'" class="fs-16 black-9 bold">Completion Notification</div>
          <div  v-else-if="templateName == 'reminder_template_id'"  class="fs-16 black-9 bold">Reminder</div>
          <div class="divider-1"></div>

          <label v-if="templateName == 'assessment_completion_notification_template_id'" class="custom-checkbox">
            <input v-model="tabData.enable_completion_notification" type="checkbox"/>

            <div class="label-text fs-12 black-9">Enable Completion Notification</div>

          </label>
        </div>
        <div class="spacer"></div>
        <div>
          <a href="" @click.prevent="createNewTemplate()" class="button btn-warning inverse uppercase fs-14 bold">Create New Template</a>
        </div>
      </div>
      <div class="divider-2"></div>

      <div class="select-box large-15">
        <div class="form-group">
          <model-select
            :options="formatTemplates"
            v-model="model.item"
            placeholder="Select Template from Existing">
          </model-select>
          <label>Select Template from Existing</label>
        </div>
      </div>

      <div class="divider-2"></div>

    </div>
    
    <hr/>
    <div class="p-20">
      <div class="form_preview">
        <div class="clearfix">
          <div class="fs-16 black-9 bold left">Form Preview:</div>

          <em v-if="isTemplateNewOrEdit" class="fs-12 black-6">&ensp;(changes saved for {{newTemplateName()}})</em>  

          <a href="" @click.prevent="editTemplate()" class="button btn-warning btn-link uppercase fs-14 bold right">Edit Template</a>
        </div>
      </div>
      <div class="preview_container black-6">
        <div class="p-20">
          <div class="clearfix">
            <strong class="large-4 columns show">From: </strong>
            <div class="large-26 columns">
              <span v-html="model.selectTemplated.from"></span>
            </div>
          </div>
          <div class="clearfix">
            <strong class="large-4 columns show">Subject: </strong>
            <div class="large-26 columns">
              <span v-html="model.selectTemplated.subject"></span>
            </div>
          </div>
        </div>

        <hr/>

        <div class="p-20">
          <p><span v-html="model.selectTemplated.body"></span></p>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="sass" scoped>
  *
    line-height: normal
  .preview_container
    background: #f6f6f6
</style>

<script>
  import { ModelSelect } from 'vue-search-select'

  export default {
    props: ['currentTemplates', 'formatTemplates', "tabData", "templateName", 'model', 'createTemplateName'],
    data() {
      return {
        templateCategoryIds: {
          create_invitation_template: 2,
          create_completion_notification_template: 21,
          create_reminder_template: 3
        }
      }
    },
    components: {
      ModelSelect
    },
    watch: {
      "model.item": function() {
        if(this.model.item.value.length !== 0) {
          this.tabData[this.templateName] = this.currentTemplates[this.model.item.value].id
          this.model.selectTemplated = this.currentTemplates[this.model.item.value]
        }
      },
      "formatTemplates": function() {
        if(this.tabData[this.templateName] != null && this.tabData[this.templateName].length !== 0) {
          const index = indexWhere(this.currentTemplates, item => item.id === this.tabData[this.templateName].toString())
          this.model.selectTemplated = this.currentTemplates[index]  
          this.model.item = { value: index, text: this.currentTemplates[index].name }
        } else {
          this.model.item = { value: '', text: ''}
          if(this.tabData[this.createTemplateName] != undefined && Object.keys(this.tabData[this.createTemplateName]).length !== 0) {
            this.model.selectTemplated = this.tabData[this.createTemplateName]
          } else {
            this.model.selectTemplated = {}  
          }
        }
      }
    },
    methods: {
      createNewTemplate() {
        this.model.create_template = {
          name: '',
          body: '',
          subject: '',
          from: '',
          template_category_id: this.templateCategoryIds[this.createTemplateName]
        }
        this.model.showModel = true
      },
      editTemplate() {
        this.model.create_template = JSON.parse(JSON.stringify(this.model.selectTemplated));
        this.model.create_template["template_category_id"] = this.templateCategoryIds[this.createTemplateName]
        this.model.showModel = true
      },
      newTemplateName() {
        return this.tabData[this.createTemplateName].name
      }
    },
    computed: {
      isTemplateNewOrEdit: function () {
        return (this.tabData[this.createTemplateName] != undefined && Object.keys(this.tabData[this.createTemplateName]).length !== 0)
      }
    }  
  }

  function indexWhere(array, conditionFn) {
    const item = array.find(conditionFn)
    return array.indexOf(item)
  }
</script>