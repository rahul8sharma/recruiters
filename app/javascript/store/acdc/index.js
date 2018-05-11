import Vue from 'vue/dist/vue.esm';

export default {
  state: {
    userId: "",
    companyId: "",
    assessmentId: "",
    assessmentName: "",
    assessmentStatus: "",
    assessmentRawData: {},
    googleDriveObjectiveQuestion: {},
    assessmentDescription: {},
    assessmentToolConfiguration: [],
    assessmentCreateCustomForms: {},
    assessmentAddBehavioursCompetenciesTraits: {},
    assessmentSelectQuestions: {},
    assessmentSelectTemplates: {},
    assessmentReportConfiguration: {},
  },
  mutations: {
    setUserId (state, payload) {
      state.userId = payload
    },
    setCompanyId (state, payload) {
      state.companyId = payload
    },
    setAssessmentId (state, payload) {
      state.assessmentId = payload
    },
    setAssessmentName (state, payload) {
      state.assessmentName = payload
    },
    setAssessmentStatus (state, payload) {
      state.assessmentStatus = payload
    },
    setAssessmentRawData (state, payload) {
      state.assessmentRawData = payload
    },
    setGoogleDriveObjectiveQuestion (state, payload) {
      state.googleDriveObjectiveQuestion = payload
    },
    setAssessmentDescription (state, payload) {
      state.assessmentDescription = payload
    },
    setAssessmentToolConfiguration (state, payload) {
      state.assessmentToolConfiguration = payload
    },
    setAssessmentCreateCustomForms (state, payload) {
      state.assessmentCreateCustomForms = payload
    },
    setAssessmentAddBehavioursCompetenciesTraits (state, payload) {
      state.assessmentAddBehavioursCompetenciesTraits = payload
    },
    setAssessmentSelectQuestions (state, payload) {
      state.assessmentSelectQuestions = payload
    },
    setAssessmentSelectTemplates (state, payload) {
      state.assessmentSelectTemplates = payload
    },
    setAssessmentReportConfiguration (state, payload) {
      state.assessmentReportConfiguration = payload
    },
    setAssessmentdata (state, payload) {
      state.assessmentName = payload.name
      state.assessmentDescription = payload.description,
      state.assessmentToolConfiguration = payload.tool_configuration,
      state.assessmentCreateCustomForms = payload.create_custom_forms,
      state.assessmentAddBehavioursCompetenciesTraits = payload.add_behaviours_competencies_traits,
      state.assessmentSelectQuestions = payload.select_questions,
      state.assessmentSelectTemplates = payload.select_templates,
      state.assessmentReportConfiguration = payload.report_configuration
    }
  },
  actions: {
    createAcdcAssessment ({commit, getters}, payload) {
      Vue.http.post('/companies/2/acdc', payload)
        .then(function (response) {
          window.location = "/companies/" + response.body.company_id + "/acdc/" + response.body.id + "/edit";
        })
        .catch(error => {
          console.log(error)
    	})
  	},
    updateAcdcAssessment ({commit, getters}, payload) {
      Vue.http.put("/companies/" + payload.companyId + "/acdc/" + payload.assessmentId, 
        { acdc_assessment: payload.acdc_assessment })
        .then(function (response) {
          return response.json()
        })
        .then(function (response) {
          commit('setAssessmentdata', response);
          commit('setAssessmentRawData', setAssessmentData(response));
        })
        .catch(error => {
          console.log(error)
        })
        return new Promise((resolve, reject) => {
          setTimeout(() => {
          resolve()
        }, 500)
      })
    },
    getAcdcAssessment ({commit, getters}, payload) {
      Vue.http.get("/companies/" + payload.companyId + "/acdc/" + payload.assessmentId)
        .then(function (response) {
            return response.json()
        })
        .then(function (response) {
          commit('setAssessmentdata', response);
          commit('setAssessmentRawData', setAssessmentData(response));
        })
        .catch(error => {
          console.log(error)
        })
    },
    getGoogleDriveFileByUrl ({commit, getters}, payload) {
      Vue.http.post("/companies/" + payload.companyId + "/acdc/get_google_drive_file_by_url", 
        { acdc_assessment: {file_url: payload.url} })
        .then(function (response) {
          return response.json()
        })
        .then(function (response) {
          commit('setGoogleDriveObjectiveQuestion', response.attributes.sections);
        })
        .catch(error => {
          console.log(error)
        })
    },
    setassessmentData ({commit, getters}, payload) {
      commit('setUserId', payload.user_id);
    },
    setUserId ({commit, getters}, payload) {
      commit('setUserId', payload.user_id);
    },
    setCompanyId ({commit, getters}, payload) {
      commit('setCompanyId', payload.company_id);
    },
    setAssessmentId ({commit, getters}, payload) {
      commit('setAssessmentId', payload.assessment_id);
    },
    setAssessmentName ({commit, getters}, payload) {
      commit('setAssessmentName', payload.assessment_name);
    },
    setAssessmentStatus ({commit, getters}, payload) {
      commit('setAssessmentStatus', payload.assessment_status);
    },
    setAssessmentRawData({commit, getters}, payload) {
      commit('setAssessmentRawData', payload.raw_data);
    }
  },
  getters: {
    userId (state) {
      return state.userId
    },
    companyId (state) {
      return state.companyId
    },
    assessmentId (state) {
      return state.assessmentId
    },
    assessmentName (state) {
      return state.assessmentName
    },
    assessmentStatus (state) {
      return state.assessmentStatus
    },
    assessmentRawData (state) {
      return state.assessmentRawData
    },
    googleDriveObjectiveQuestion (state) {
      return state.googleDriveObjectiveQuestion
    },
    assessmentDescription (state) {
      return state.assessmentDescription
    },
    assessmentToolConfiguration (state) {
      return state.assessmentToolConfiguration
    },
    assessmentCreateCustomForms (state) {
      return state.assessmentCreateCustomForms
    },
    assessmentAddBehavioursCompetenciesTraits (state) {
      return state.assessmentAddBehavioursCompetenciesTraits
    },
    assessmentSelectQuestions (state) {
      return state.assessmentSelectQuestions
    },
    assessmentSelectTemplates (state) {
      return state.assessmentSelectTemplatess
    },
    assessmentReportConfiguration (state) {
      return state.assessmentReportConfiguration
    }
  }
};

function setAssessmentData(response) {
  return {
    'tools': response.tools,
    'description': response.description,
    'tool_configuaration': response.tool_configuration,
    'create_custom_forms': response.create_custom_forms,
    'add_behaviours_competencies_traits': response.add_behaviours_competencies_traits,
    'select_subjective_objective_questions': response.select_questions,
    'select_template': response.select_templates,
    'report_configuration': response.report_configuration,
    'review': {}
  }
}