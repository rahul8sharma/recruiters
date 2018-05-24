<template>
  <div class="modal scrollable hide" id="modal">
    <div class="modal-container large-20 p-0">
      <div class="heading fs-14 uppercase bold">
        <span>Edit Template ff</span>
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
                  <input id="template_from" v-model="model.create_template.from" type="text" placeholder="From"/>
                  <label>From</label>
                </div>
              </div>

              <div class="clearfix fs-16  black-9">
                <div class="large-5 columns bold line-height-4">Subject:  </div>
                <div class="form-group large-25 columns bold">
                  <input id="template_subject" v-model="model.create_template.subject" type="text" placeholder="Subject"/>
                  <label>Subject</label>
                </div>
              </div>
            </div>

            <hr/>

            <div class="text_editor">
              <trumbowyg v-model="model.create_template.body"
                id="template_html_editor"
                :config="configs"
                class="form-control"
                name="content">
              </trumbowyg>
            </div>

          </div>

          <div class="template_variables large-10 ">
            <div class="p-18">
              <div class="fs-16 black-9">Template Variables:</div>
              <em class="fs-12 black-6">(Click on a template variable to add it to the template body)</em>
              <div class="divider-1"></div>
              <ul id="template_variables">
                <li v-for="(templateVariable, index) in templateVariables">
                  <a href='javascript:void(0);' class="variables template_variable_link" :templatevariablename="templateVariable.id">{{index+1}}. {{templateVariable.name}}</a>
                </li>
              </ul>
            </div>  
          </div>
          

        </div>

        <div class="actions">
          <div class="spacer"></div>
          <button @click="saveTemplate()" class="button btn-warning uppercase fs-14">Save</button>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
  import trumbowyg from 'vue-trumbowyg';
  import 'trumbowyg/dist/ui/trumbowyg.css';
  import assessmentHelper from 'helpers/assessment.js'

  export default {
    props: ['currentTemplates', "tabData", "templateName", 'model', 'createTemplateName', 'templateVariables'],
    data() {
      return {
        content: '',
        configs: {
          autogrow: true,
          autogrowOnEnter: true,
          removeformatPasted: true,
          btnsAdd: ['foreColor', 'backColor'],
          btns: [
            ['formatting'],
            ['strong', 'em', 'del'],
            ['superscript', 'subscript'],
            ['link'],
            ['insertImage'],
            ['justifyLeft', 'justifyCenter', 'justifyRight', 'justifyFull'],
            ['unorderedList', 'orderedList'],
            ['horizontalRule'],
            ['removeformat'],
            ['fullscreen']
          ]
        },
        currentElements: 'template_html_editor',
      }
    },
    components: {
      trumbowyg
    },
    methods: {
      saveTemplate(){
        this.tabData[this.createTemplateName] = this.model.create_template
        this.model.showModel = false
        this.model.selectTemplated = this.model.create_template

        for(var templateVariableIndex=0; templateVariableIndex < this.templateVariables.length; templateVariableIndex++) {
          this.model.selectTemplated.from = this.model.create_template.from.replace("<$" + this.templateVariables[templateVariableIndex].id + "$>", "&lt;" + this.templateVariables[templateVariableIndex].name + "&gt;");
          this.model.selectTemplated.subject = this.model.create_template.subject.replace("<$" + this.templateVariables[templateVariableIndex].id + "$>", "&lt;" + this.templateVariables[templateVariableIndex].name + "&gt;");
          this.model.selectTemplated.body = this.model.create_template.body.replace("&lt;$" + this.templateVariables[templateVariableIndex].id + "$&gt;", "&lt;" + this.templateVariables[templateVariableIndex].name + "&gt;");
        }
        this.tabData[this.templateName] = ''
        this.model.item = { value: '', text: ''}
      }
    },
    mounted: function (){
      let vm = this
      setTimeout(function() {
        document.getElementById("modal").classList.remove("hide");
        document.getElementById("modal").classList.add("modalOpen");
      }, 0);

      function checkEmailBodyForVaribales(){
        var html =  $('#template_html_editor').html();
        html = html.replace(/\&lt;/gi,"<").replace(/\&gt;/gi,">");
        setTemplateBodyValue(html);
        if (html.match(/\<\$(.*?)\$\>/gi) == null){
          var prompt = confirm("You have not added template varibales to email body.");
          if (prompt == true){
            return true;
          }else{
            return false;
          }
        }else{
          return true;
        }
      }

      jQuery(document).ready(function($){
        var currentElement = null;
        var editor = $('#template_html_editor');


        getTemplateBodyValue($('input[name="template[body]"').val(), editor);

        $(document).on("click","#template_subject, #template_from",function() {
          currentElement = $(this);
        });

        $(document).on("tbwfocus","#template_html_editor",function() {
          currentElement = $(this);
        });
        $(document).on("tbwinit","#template_html_editor",function() {
          currentElement = $(this);
        });

        $(document).on("click",".template_variable_link",function(){
          if(currentElement != null) {
            var template_variable = "<$"+$(this).attr("templatevariablename")+"$>";
            if(currentElement.attr('id') == "template_html_editor"){
                var link = $(['<span>', template_variable, '</span>'].join(''));
                editor.trumbowyg('saveRange');
                editor.trumbowyg('getRange').deleteContents();
                editor.trumbowyg('getRange').insertNode(link.get(0));
                editor.trumbowyg('restoreRange');
                editor.trumbowyg('saveRange');
                setTemplateBodyValue($('#template_html_editor').html());
            }else{
              assessmentHelper.insertAtCursor(document.getElementById(currentElement.attr('id')), template_variable);
            }
          }
        });
      });

      function setTemplateBodyValue(value){
        $('input[name="template[body]"').attr('value', value);
      }
      function getTemplateBodyValue(value, editor){
        editor.trumbowyg('html', value);
      }
  }
}
</script>
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