<template>
  <div class="wrapper">
    <loader></loader>
    <div class="divider-2"></div>
    <div class="container">
      <button @click="setModalState" class="button btn-warning big big-text right uppercase">Create Assessment</button>
      <div class="clr"></div>
      <CreateAssessment
        v-bind:isModalOpen="modal.isOpen"
        v-bind:isCreateSubmitButtonEnable="isCreateSubmitButtonEnable"
        v-bind:assessment="assessment"
        v-bind:products="products"
        :set-modal-state="setModalState"
        :create-assessment="createAssessment"
      >
      </CreateAssessment>
    </div>
  </div>
</template>

<script>
  import CreateAssessment from 'components/acdc/assessments/New.vue';
  import Loader from 'components/shared/loader.vue';

  export default {
    components: { CreateAssessment, Loader },
    data () {
      return {
        modal: {
          isOpen: false
        },
        products: [],
        assessment: {
          name: '',
          tools: [],
          product: ''
        }
      }
    },
    methods: {
      setModalState () {
        this.modal.isOpen = !this.modal.isOpen;
      },
      createAssessment () {
        if (this.assessment.product != 'psychometry') {
          this.assessment.tools.push('psychometry')
        }
        if (this.assessment.product != 'mini_hive') {
          this.assessment.tools.push(this.assessment.product)
        }
        let assessmentRawData = {
          product_id: '',
          tools: this.assessment.tools,
          description_tab: {
            industry_id: {value: '', text: ''},
            functional_area_id: {value: '', text: ''},
            job_experience_id: {value: '', text: ''},
            enable_proctoring: false
          },
          tool_configuaration_tab: [],
          create_custom_forms_tab: {},
          add_behaviours_competencies_traits_tab: {},
          select_subjective_objective_questions_tab: {
            objective_question: {
              weightage: '',
              is_question_uploaded: false,
              sections: []
            },
            subjective_question: {
              questions: []
            }
          },
          select_template_tab: {},
          report_configuration_tab: {},
          review_tab: {}
        }
        this.$store.dispatch('createAcdcAssessment', {
          acdc_assessment: {
            name: this.assessment.name,
            company_id: this.$store.getters.companyId,
            user_id: this.$store.getters.userId,
            raw_data: assessmentRawData
          }
        })
      }
    },
    computed: {
      isCreateSubmitButtonEnable () {
        return !(this.assessment.name != '' && this.assessment.tool != '' )
      }
    },
    created: function() {
      this.get.products({company_id: 2})
        .then(response => {
        return response.json()
      })
      .then(data => {
        this.products = data
      })
    }
  }
</script>