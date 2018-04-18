<template>
  <div class="wrapper">
    <Header></Header>
    <div class="divider-2"></div>
    <div class="container">
      <a href="#" class="button btn-warning big big-text right uppercase">Create Assessment</a>
      <div class="clr"></div>
      <div class="modal scrollable">
        <div class="modal-container large-20">
          <div class="heading fs-14 uppercase">
            <span>Create Assessment</span>
            <div class="spacer"></div>
            <div class="close">&times;</div>  
          </div>
          <div class="modal-body">
            <CreateAssessment></CreateAssessment>
          </div>
          <div class="actions">
            <div class="spacer"></div>
            <a href="" class="button btn-link uppercase fs-14 black-7">Discard</a>
            <a href="" disabled class="button btn-warning uppercase fs-14">Create Assessment</a>
          </div>
        </div>
      </div>
    </div>
     
        

    <Footer></Footer>
  </div>
</template>

<script>
    import Header from 'components/shared/Header.vue';
    import CreateAssessment from 'components/acdc/assessments/New.vue';
  //   import VueScrollbar from 'vue2-scrollbar';
  // require("vue2-scrollbar/dist/style/vue2-scrollbar.css")
    import Footer from 'components/shared/Footer.vue';
  export default {
    components: { Header, Footer, CreateAssessment },
    data () {
          return {
          text: 'Hello World!'
        }
    }
  }
</script>