import Vue from 'vue/dist/vue.esm';
export default {
    state: {
      acdc_assessment: {
      	raw_data: {}
      }
  	},
    mutations: {
      setAcdcAssessment (state, payload) {
      	state.acdc_assessment = payload
      },
      setAcdcAssessmentRawData (state, payload) {
      	state.acdc_assessment.raw_data = payload
      }
    },
    actions: {
      create_acdc_assessment ({commit, getters}, payload) {
	      Vue.http.post('/companies/2/acdc', payload)
        .then(function (response) {
            commit('setAcdcAssessment', response.body);
        })
        .catch(error => {
          console.log(error)
      	})
	  	},
	  	show_acdc_assessment ({commit, getters}, payload) {
	      Vue.http.get('/companies/2/acdc/1')
	      .then(function (response) {
            commit('setAcdcAssessment', response.body);
        })
        .catch(error => {
          console.log(error)
      	})
	  	},
	  	update_acdc_assessment ({commit, getters}, payload) {
	      Vue.http.put('/companies/2/acdc/1', payload)
	      .then(function (response) {
            commit('setAcdcAssessment', response.body);
        })
        .catch(error => {
          console.log(error)
      	})
	  	},
	  	fetch_meta_data ({commit, getters}, payload) {
	      Vue.http.get('/companies/2/acdc/meta_data')
	      .then(function (response) {
            commit('setAcdcAssessmentRawData', response.body);
        })
        .catch(error => {
          console.log(error)
      	})
	  	}
	  },
    getters: {
    	acdc_assessment (state) {
    		return state.acdc_assessment
  		}
    },
};