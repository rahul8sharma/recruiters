<template>
  <div>
    <div class="p-20">
      <div class="divider-1"></div>
      <div class="flex-box">
        <div>
          <div class="fs-16 black-9 bold">Invitation Template</div>
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
    props: ['currentTemplates', 'formatTemplates', "tabData", "templateName", 'model', 'model.item'],
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
          this.model.selectTemplated = {}  
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
          template_category_id: 20
        }
        this.model.showModel = true
      },
      editTemplate() {
        // this.model.create_template = JSON.parse(JSON.stringify(this.model.selectTemplated));
        this.model.create_template = this.model.selectTemplated;
        this.model.showModel = true
      }
    }
  }

  function indexWhere(array, conditionFn) {
    const item = array.find(conditionFn)
    return array.indexOf(item)
  }
</script>