<template>
  <div>
    <div class="action_bar">
      <div class="fs-16 black-9 link_breadcrumb uppercase">
        <a href="" class="active">A. Add Objective Questions</a>
        <a href="">B. Add Subjective Questions</a>
      </div>

      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos necessitatibus, facilis dolorum, impedit fugit voluptatibus nemo unde ut a dolore vero quo sint perspiciatis. Exercitationem saepe cum a vitae! Eligendi.
          </div>
        </div>
      </div>
     
      <button class="button btn-warning uppercase fs-14">
        Save &amp; Next
      </button>
    </div>
    
    <div class="edit_section">
      <button @click="changeQuestionType()">Objective Question</button>
      <button @click="changeQuestionType()">Subjective Question</button>
      <component
        v-if="isObjective"
        v-for="(questionType, index) in tabData"
        v-bind:key="index"
        v-bind:is="Object.keys(questionType)[0]"
        v-bind:objectiveQuestion="tabData.raw_data[Object.keys(questionType)[0]]"
      >
      </component>

      <component
        v-if="!isObjective"
        v-for="(questionType, index) in tabData"
        v-bind:key="index"
        v-bind:is="Object.keys(questionType)[1]"
        v-bind:subjectiveQuestion="tabData.raw_data[Object.keys(questionType)[1]]"
      >
      </component>
      <div class="divider-4"></div>
    </div>
  </div>

</template>

<script>
  import objective_question from 'components/acdc/assessments/tabs/select_questions/ObjectiveQuestions.vue'
  import subjective_question from 'components/acdc/assessments/tabs/select_questions/SubjectiveQuestions.vue'
  export default {
    props: ['tabData'],
    data () {
      return  {
        isObjective: true
      }
    },
    components: { objective_question,  subjective_question },
    methods: {
      changeQuestionType() {
        this.isObjective = !this.isObjective
      }
    }
  }
</script>