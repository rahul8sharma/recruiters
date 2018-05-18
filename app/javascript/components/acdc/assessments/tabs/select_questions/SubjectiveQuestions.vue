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
  import assessmentHelper from 'helpers/assessment.js'

  export default {
    props: ['subjectiveQuestion'],
    data() {
      return {
        content: ''
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
        return this.content.trim().length == 0
      }
    },
    mounted: function () {
      document.getElementById('addBlankButton').onclick = function() {
        assessmentHelper.insertAtCursor(document.getElementById('questionEditor'), '< > Blank');
      };
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