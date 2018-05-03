<template>
  <div class="edit_section p-0">
    <div class="p-30">
      <vue-editor v-model="content" :editorToolbar="customToolbar"></vue-editor>
      <button :disabled="isAddButton" @click="addQuestion" class="button btn-warning btn-link uppercase bold line-height-2">Add</button>
    </div>

    <hr/>


    <div class="questions p-30">
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
    }
  }
</script>

<style lang="sass" scoped>
  .questions
    max-height: 215px
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