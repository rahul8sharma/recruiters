<template>
  <div class="wrapper">
    <loader></loader>

    <div class="divider-1"></div>
    <div class="container flex-box">
      <div class="fs-18 black-10">
        In-draft assessments
        <br>
        <em class="black-7 fs-14">showing 25 of 123 results</em>
      </div>
      <div class="spacer"></div>
      <button @click="setModalState" class="button btn-warning big big-text uppercase">Create Assessment</button>
    </div>

    <div class="divider-1"></div>

    <CreateAssessment
      v-bind:isModalOpen="modal.isOpen"
      v-bind:isCreateSubmitButtonEnable="isCreateSubmitButtonEnable"
      v-bind:assessment="assessment"
      v-bind:products="products"
      :set-modal-state="setModalState"
      :create-assessment="createAssessment"
    >
    </CreateAssessment>

    <div class="listing">
      <div class="headings uppercase black-9 fs-14 bold">
        <div class="container flex-box clearfix pt-16 pb-16">
          <div class="large-2 iconic">
            AID
            <span class="icon_up hide">&#9650;</span>
            <span class="icon_down">&#9660;</span>
          </div>
          <div class="large-10 iconic">
            Assessment Title
            <span class="icon_up hide">&#9650;</span>
            <span class="icon_down">&#9660;</span>
          </div>
          <div class="large-4 iconic">
            Created on 
            <span class="icon_up hide">&#9650;</span>
            <span class="icon_down">&#9660;</span>
          </div>
          <div class="large-4">Status</div>
          <div class="large-4">Actions</div>
          
        </div>
      </div>
      <div class="list">
        <ul>
          <li class="pt-16 pb-16" v-for="assessment in allAssessment">
            <div class="container flex-box">
              <div class="large-2">{{assessment.attributes.id}}</div>
              <div class="large-10 ">
                <a href="javascript:void(0)">
                  <div class="truncate">{{assessment.attributes.name}}</div>
                  <div class="info_container fs-14">
                    <div class="info p-10 black-6">
                      <div class="clearfix p-8">
                        <div class="bold large-10 columns black-9">Name</div>
                        <div class="large-20 columns">{{assessment.attributes.name}}</div>
                      </div>

                      <div class="clearfix p-8">
                        <div class="bold large-10 columns black-9">Type</div>
                        <div class="large-20 columns">
                          <span>ToDo Name of product</span>
                          <br/>
                          <em class="fs-12">{{splitToolsName(assessment.attributes.tools)}}</em>
                        </div>
                      </div>
                      
                      <div class="clearfix p-8">
                        <div class="bold large-10 columns black-9">Language</div>
                        <div class="large-20 columns">{{getlanguages(assessment.attributes.tool_configuration)}}</div>
                      </div>
                      
                      <div class="clearfix p-8">
                        <div class="bold large-10 columns black-9">Purpose</div>
                        <div class="large-20 columns">{{getPurpose(assessment.attributes.tool_configuration)}}</div>
                      </div>


                    </div>
                  </div>

                </a>
              </div>
              <div class="large-4">{{assessment.attributes.created_at.split('T')[0]}}</div>
              <div class="large-4">{{assessment.attributes.status}}</div>
              <div class="large-4">
                <a v-bind:href="getAssessmentEditUrl(assessment.attributes.id)" class="bold">Edit Assessment</a>
              </div>
            </div>
          </li>
        </ul>
        <div class="divider-12"></div>
      </div>
    </div>
    <div class="pagination">
      <div class="container">
        1 2 3
      </div>
    </div>
  </div>
</template>

<script>
  import CreateAssessment from 'components/acdc/assessments/New.vue';
  import Loader from 'components/shared/loader.vue';
  import assessmentHelper from 'helpers/assessment.js'
  import assessmentUrlHelper from 'helpers/assessmentUrl.js'

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
        },
        allAssessment: {}
      }
    },
    methods: {
      setModalState () {
        this.modal.isOpen = !this.modal.isOpen;
      },
      createAssessment () {
        if (this.assessment.product != 'psychometry') {
          this.assessment.tools.unshift('psychometry')
        }
        if (this.assessment.product != 'mini_hive') {
          this.assessment.tools.push(this.assessment.product)
        }
        let description = {
          industry_id: { text:'', value: ''},
          functional_area_id: { text:'', value: ''},
          job_experience_id: { text:'', value: ''},
          enable_proctoring: false
        }
        let tool_configuration = []
        let create_custom_forms = {
          defined_form_id: { text:'', value: ''},
          defined_form: {}
        }
        let add_behaviours_competencies_traits = {
          competencies: [{
            name: '',
            description: "-",
            modules: ["suitability"],
            factor_ids: [],
            company_ids: [this.$store.state.AcdcStore.companyId],
            weight: 1.0,
            order: 0,
            selectedFactors: [{
              factor_id: '',
              name: '',
              from_norm_bucket: {value: '', text: ''},
              to_norm_bucket: {value: '', text: ''},
              weight: 1.0
            }]
          }],
          job_assessment_factor_norms_attributes: [{
            factor_id: '',
            name: '',
            from_norm_bucket_id: 0,
            to_norm_bucket_id: 0,
            weight: 1
          }],
          showCompetencyScoreOnReport: false,
          showConsistencyScoreOnReport: false,
          showTraitConsistencyScoresonReport: false
        }
        let select_questions = {
          objective_question: {
            weightage: '',
            is_question_uploaded: false,
            sections: []
          },
          subjective_question: {
            questions: []
          }
        }
        let select_templates = {
          invitation_template_id: '',
          assessment_completion_notification_template_id: '',
          reminder_template_id: '',
          enable_completion_notification: false,
          create_invitation_template: {},
          create_completion_notification_template: {},
          create_reminder_template: {}
        }
        let report_configuration = {
          html: [],
          pdf: []
        }
        this.$store.dispatch('createAcdcAssessment', {
          acdc_assessment: {
            name: this.assessment.name,
            company_id: this.$store.getters.companyId,
            user_id: this.$store.getters.userId,
            description: description,
            tool_configuration: tool_configuration,
            create_custom_forms: create_custom_forms,
            add_behaviours_competencies_traits: add_behaviours_competencies_traits,
            select_questions: select_questions,
            select_templates: select_templates,
            report_configuration: report_configuration,
            product_id: '',
            tools: this.assessment.tools
          }
        })
      },
      splitToolsName(tools) {
        return assessmentHelper.splitToolsName(tools)
      },
      getlanguages(tool_configurations) {
        return assessmentHelper.getlanguages(tool_configurations[0])
      },
      getPurpose(tool_configurations) {
        return assessmentHelper.getPurpose(tool_configurations[0])
      },
      getAssessmentEditUrl(id) {
        return assessmentUrlHelper.getAssessmentEditUrl(this.$store.state.AcdcStore.companyId, id)
      }
    },
    computed: {
      isCreateSubmitButtonEnable () {
        if (this.assessment.product == 'mini_hive') {
          return !(this.assessment.name != '' && this.assessment.tools.length != 0 )
        } else {
          return !(this.assessment.name != '' && this.assessment.product != '' )
        }
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
      this.$store.dispatch('setAllAssessment', {
        companyId: this.$store.state.AcdcStore.companyId
      })
    },
    watch: {
      '$store.state.AcdcStore.allAssessment' (newCount, oldCount) {
        this.allAssessment = this.$store.state.AcdcStore.allAssessment
      }
    }
  }
</script>
<style lang="sass">
  @import '~assets/css/shared/index' 
</style>
<style lang="sass" scoped>
  .list
    overflow-y: auto
    height: calc(100vh - 185px)
</style>
