<template>
  <div class=" subjective_questions">
    <div class="p-20">
      <div class="question_editor">
        <textarea v-model="content" placeholder="Enter a Question" id="" cols="30" rows="3" data-gramm_editor="false" id="questionEditor"></textarea>

        <div class="action_bar">
          <button id="addBlankButton" class="button btn-default btn-link fs-16 line-height-2 black-10 p-0">
            &lt; &gt; Add Blank
          </button>
          <div class="spacer"></div>
          <button :disabled="isAddButton" @click="addQuestion" class="button btn-warning uppercase bold">Add</button>
        </div>
      </div>

      <!-- <vue-editor v-model="content" :editorToolbar="customToolbar"></vue-editor> -->
    </div>

    <hr/>

    <div class="questions p-30" v-if="subjectiveQuestion.questions.length">
      <div class="fs-15 black-10 bold">Questions</div>
      <ul class="questions_list">
        <li class="questions_item" v-for="(question, index) in subjectiveQuestion.questions">
          <div class="large-20 left" v-html="question"></div>
          <div class="large-10 left">
            <button @click="removeQuestion(index)" class="button btn-warning btn-link uppercase bold line-height-2">remove</button>
          </div> 
          <div class="clr"></div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
  import { VueEditor } from 'vue2-editor'

  export default {
    props: ['subjectiveQuestion'],
    components: { VueEditor },
    data() {
      return {
        content: '',
        customToolbar: [
            ['bold', 'italic']
          ]
      }
    },
    methods: {
      addQuestion() {
        this.subjectiveQuestion.questions.push(this.content)
        this.content = ''
      },
      removeQuestion(index) {
        this.subjectiveQuestion.questions.splice(index, 1)
      }
    },
    computed: {
      isAddButton: function () {
        return this.content == ''
      }
    },
    mounted: function () {
      //Insert Blank where the cursor is
      function insertAtCursor(myField, myValue) {
        //IE support
        if (document.selection) {
          myField.focus();
          sel = document.selection.createRange();
          sel.text = myValue;
        }
        // Microsoft Edge
        else if(window.navigator.userAgent.indexOf("Edge") > -1) {
          var startPos = myField.selectionStart; 
          var endPos = myField.selectionEnd; 

          myField.value = myField.value.substring(0, startPos)+ myValue 
          + myField.value.substring(endPos, myField.value.length); 
          
          var pos = startPos + myValue.length;
          myField.focus();
          myField.setSelectionRange(pos, pos);
        }
        //MOZILLA and others
        else if (myField.selectionStart || myField.selectionStart == '0') {
          var startPos = myField.selectionStart;
          var endPos = myField.selectionEnd;
          myField.value = myField.value.substring(0, startPos)
          + myValue
          + myField.value.substring(endPos, myField.value.length);
        } else {
          myField.value += myValue;
        }
      };

      document.getElementById('addBlankButton').onclick = function() {
        insertAtCursor(document.getElementById('questionEditor'), '< > Blank');
      }; 
      // let customTag = document.querySelector('.ql-formats');
      // customTag.innerHTML = customTag.innerHTML +  '<button type="button" class="add-blank-button" style="width: 71px;">' +
      //   '<svg style="width: 91px;">' +
      //   '<text x="0" y="15">&lt;&gt;Add Blank</text>' +
      //   '</svg>' +
      //   '</button>';
      // let customButton = document.querySelector('.add-blank-button');
      // customButton.addEventListener('click', function() {
      //   let editor = document.querySelector('.ql-editor')
      //   editor.innerHTML = [editor.innerHTML.slice(0, editor.innerHTML.length - 4), '<>Add Blank', editor.innerHTML.slice(editor.innerHTML.length - 4)].join('');
      // });
    }
  }
</script>

<style lang="sass" scoped>
  .question_editor
    background: #f6f6f6
    padding: 3px
    textarea
      background: #f6f6f6
    .action_bar
      background: #fff
      border: 0 none
      box-shadow: 0 0 0 transparent
      padding: 0 15px
  .questions
    max-height: 250px
    overflow: auto
  .questions_list
    padding-left: 20px
    .questions_item
      list-style-type: decimal
      padding: 15px 0
      color: rgba(0, 0, 0, 0.6)
      .blank
        color: rgba(0, 0, 0, 0.9)
        font-weight: 600
</style>