import Vue from 'vue/dist/vue.esm';
export default {
  state: {},
  mutations: {},
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
  },
  getters: {}
};