<template>
  <div class="wrapper">
    <Header></Header>
    <div class="divider-2"></div>
    <div class="container">
      <button @click="setModalState" class="button btn-warning big big-text right uppercase">Create Assessment</button>
      <div class="clr"></div>
      <CreateAssessment
        v-bind:isModalOpen="modal.isOpen"
        v-bind:isCreateSubmitButtonEnable="isCreateSubmitButtonEnable"
        v-bind:assessment="assessment"
        :set-modal-state="setModalState"
        :create-assessment="createAssessment"
      >
      </CreateAssessment>
    </div>
    <Footer></Footer>
  </div>
</template>

<script>
  import Header from 'components/shared/Header.vue';
  import Footer from 'components/shared/Footer.vue';
  import CreateAssessment from 'components/acdc/assessments/New.vue';

  export default {
    components: { Header, Footer, CreateAssessment },
    data () {
      return {
        modal: {
          isOpen: false
        },
        assessment: {
          name: '',
          tool: ''
        }
      }
    },
    methods: {
      setModalState () {
        this.modal.isOpen = !this.modal.isOpen;
      },
      createAssessment () {
          console.log("Called...")
          this.$store.dispatch('createAcdcAssessment', {
              acdc_assessment: {
                  name: this.assessment.name,
                  company_id: 2,
                  user_id: 176698,
                  raw_data: {tool: this.assessment.tool}
              }
          })
      }
    },
    computed: {
      isCreateSubmitButtonEnable () {
        return !(this.assessment.name != '' && this.assessment.tool != '' )
      }
    }
  }
</script>