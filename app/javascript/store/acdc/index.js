import Vue from 'vue/dist/vue.esm';

export default {
  state: {
    userId: "",
    companyId: "",
    assessmentId: ""
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
    setUserId ({commit, getters}, payload) {
      commit('setUserId', payload.user_id);
    },
    setCompanyId ({commit, getters}, payload) {
      commit('setCompanyId', payload.company_id);
    },
    setAssessmentId ({commit, getters}, payload) {
      commit('setAssessmentId', payload.assessment_id);
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
    }
  }
};