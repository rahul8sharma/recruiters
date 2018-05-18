<template>
  <div class="modal scrollable modalOpen">
    <div class="modal-container large-20 p-0">
      <div class="heading fs-14 uppercase bold">
        <span>Edit Template</span>
        <div class="spacer"></div>
        <div @click.prevent="model.showModel=false" class="close">&times;</div>
      </div>

      <div class="modal-body p-0 ">
        <div class="create_new_template flex-box">
          <div class="large-20 ">
            <div class="p-30 pb-0">
              <div class="clearfix fs-16  black-9">
                <div class="large-5 columns bold line-height-4">Name:  </div>
                <div class="form-group large-25 columns bold">
                  <input value="" v-model="model.create_template.name" type="text" placeholder="name"/>
                  <label>name</label>
                </div>
              </div>

              <div class="clearfix fs-16  black-9">
                <div class="large-5 columns bold line-height-4">From: </div>
                <div class="form-group large-25 columns bold">
                  <input v-model="model.create_template.from" type="text" placeholder="From"/>
                  <label>From</label>
                </div>
              </div>

              <div class="clearfix fs-16  black-9">
                <div class="large-5 columns bold line-height-4">Subject:  </div>
                <div class="form-group large-25 columns bold">
                  <input v-model="model.create_template.subject" type="text" placeholder="Subject"/>
                  <label>Subject</label>
                </div>
              </div>
            </div>

            <hr/>

            <div class="text_editor">
              <vue-editor class="large" :editorToolbar="customToolbar" v-model="model.create_template.body"></vue-editor>
            </div>

          </div>

          <div class="template_variables large-10 ">
            <div class="p-18">
              <div class="fs-16 black-9">Template Variables:</div>
              <em class="fs-12 black-6">(Click on a template variable to add it to the template body)</em>
              <div class="divider-1"></div>
              <ul>
                <li v-for="(templateVariable, index) in templateVariables">
                  <a @click="setVariable(templateVariable.id)" class="variables">{{index+1}}. {{templateVariable.name}}</a>
                </li>
              </ul>
            </div>  
          </div>
          

        </div>

        <div class="actions">
          <div class="large-10">
            <a href="" class="p-10 black-9 bold">&lt; &gt;</a>
            <a href="" class="p-10 black-9">
              <img src="~assets/images/ic-attachment.svg" alt="">
            </a>
          </div>
          <div class="spacer"></div>
          <button @click="saveTemplate()" class="button btn-warning uppercase fs-14">Save</button>
        </div>
      </div>
    </div>
  </div>
</template>
<style lang="sass" scoped>
  .text_editor
    min-height: 200px
  .create_new_template
    align-items: stretch !important
  .template_variables
    border-left: 2px solid rgba(0, 0, 0, 0.1)
    .variables
      color: rgba(0, 0, 0, 0.54)
      text-decoration: underline
      font-size: 14px

      &:hover
        opacity: 0.6
    
</style>
<script>
  import { VueEditor } from 'vue2-editor'
  export default {
    props: ['currentTemplates', "tabData", "templateName", 'model', 'createTemplateName', 'templateVariables'],
    data() {
      return {
        customToolbar: [
          [{ 'header': [false, 1, 2, 3, 4, 5, 6, ] }],
          ['bold', 'italic', 'underline', 'strike'],
          [{'align': ''}, {'align': 'center'}, {'align': 'right'}, {'align': 'justify'}],
          ['blockquote', 'code-block'],
          [{ 'list': 'ordered'}, { 'list': 'bullet' }],
          [{ 'indent': '-1'}, { 'indent': '+1' }],
          [{ 'color': [] }, { 'background': [] }],
        ]
      }
    },
    components: {
      VueEditor
    },
    methods: {
      saveTemplate(){
        this.tabData[this.createTemplateName] = this.model.create_template
        this.model.showModel = false
        this.model.selectTemplated = this.model.create_template
        this.tabData[this.templateName] = ''
        this.model.item.value =  ''
        this.model.item.text = ''
      },
      setVariable(id) {
        // this.model.create_template.body = this.model.create_template.body + "<p><$" + id +  "$></p>"
        let editor = document.querySelector('.ql-editor')
        editor.innerHTML = [editor.innerHTML.slice(0, editor.innerHTML.length - 4), "<p><$" + id +  "$></p>", editor.innerHTML.slice(editor.innerHTML.length - 4)].join('');
      }
    }
  }
</script>