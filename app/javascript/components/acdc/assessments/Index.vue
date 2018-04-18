<template>
  <div class="wrapper">
    <Header></Header>
    <AssessmentCRUD></AssessmentCRUD>
    <div class="divider-2"></div>
    <div class="container">
      <button @click="setModalState" class="button btn-warning big big-text right uppercase">Create Assessment</button>
      <div class="clr"></div>
      <CreateAssessment v-bind:isModalOpen="isModalOpen" :set-modal-state="setModalState"></CreateAssessment>
    </div>
    <Footer></Footer>
  </div>
</template>

<script>
  import Header from 'components/shared/Header.vue';
  import Footer from 'components/shared/Footer.vue';
  import CreateAssessment from 'components/acdc/assessments/New.vue';
  import AssessmentCRUD from 'components/acdc/assessments/AssessmentCRUD.vue';

  export default {
    components: { Header, Footer, CreateAssessment, AssessmentCRUD },
    data () {
      return {
        isModalOpen: false
      }
    },
    methods: {
      setModalState () {
        this.isModalOpen = !this.isModalOpen;
      }
    }
  }
</script>