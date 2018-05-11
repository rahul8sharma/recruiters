<template>
  <div>
    <div class="p-20">
      <div class="divider-1"></div>
      <div class="flex-box">
        <div>
          <div class="fs-16 black-9 bold">Invitation Template</div>
          <div class="divider-1"></div>
          <label v-if="templateName == 'completion_notification_template_id'" class="custom-checkbox">
            <input v-model="tabData.disableAssessmentCompletionNotification" type="checkbox"/>

            <div class="label-text fs-12 black-9">Disable assessment completion notification</div>

          </label>
        </div>
        <div class="spacer"></div>
        <div>
          <a href="" class="button btn-warning inverse uppercase fs-14 bold">Create New Template</a>
        </div>
      </div>
      <div class="divider-2"></div>

      <div class="select-box large-15">
        <div class="form-group">
          <model-select
            :options="formatTemplates"
            v-model="item"
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
          <a href="" class="button btn-warning btn-link uppercase fs-14 bold right">Edit Template</a>
        </div>
      </div>
      <div class="preview_container black-6">
        <div class="p-20">
          <div class="clearfix">
            <strong class="large-4 columns show">From: </strong>
            <div class="large-26 columns">
              <span v-html="selectTemplated.from"></span>
            </div>
          </div>
          <div class="clearfix">
            <strong class="large-4 columns show">Subject: </strong>
            <div class="large-26 columns">
              <span v-html="selectTemplated.subject"></span>
            </div>
          </div>
        </div>

        <hr/>

        <div class="p-20">
          <p><span v-html="selectTemplated.body"></span></p>
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
    props: ['currentTemplates', 'formatTemplates', "tabData", "templateName"],
    data () {
      return {
        item: {
          value: '',
          text: ''
        },
        selectTemplated: {},
      }
    },
    components: {
      ModelSelect
    },
    watch: {
      item: function() {
        if(this.item.value.length !== 0) {
          this.tabData[this.templateName] = this.currentTemplates[this.item.value].id
          this.selectTemplated = this.currentTemplates[this.item.value]  
        }
      },
      "formatTemplates": function() {
        if(this.tabData[this.templateName] != null && this.tabData[this.templateName].length !== 0) {
          const index = indexWhere(this.currentTemplates, item => item.id === this.tabData[this.templateName].toString())
          this.selectTemplated = this.currentTemplates[index]  
          this.item = { value: index, text: this.currentTemplates[index].name }
        } else {
          this.item = { value: '', text: ''}
          this.selectTemplated = {}  
        }
      }
    }
  }

  function indexWhere(array, conditionFn) {
    const item = array.find(conditionFn)
    return array.indexOf(item)
  }
</script>