import Vue from 'vue/dist/vue.esm';

export default {
  state: {
    htmlReportConfiguration: [],
    pdfReportConfiguration: [],
    errorReportConfiguration: []
  },
  mutations: {
    setHtmlReportConfiguration (state, payload) {
      state.htmlReportConfiguration = payload
    },
    setPdfReportConfiguration (state, payload) {
      state.pdfReportConfiguration = payload
    },
    setErrorReportConfiguration (state, payload) {
      state.errorReportConfiguration = payload
    }
  },
  actions: {
    getReportConfiguration ({commit, getters}, payload) {
      let reportConfiguration = []
      Vue.http.get('/report_configurations/load_configuration/?report_type=oac&assessment_type=super_competency&company_id=2')
        .then(function (response) {
          let config = JSON.parse(response.data.config);
          commit('setErrorReportConfiguration', response.data.error);
          commit('setHtmlReportConfiguration', config.html.sections);
          commit('setPdfReportConfiguration', config.pdf.sections);
        })
        .catch(error => {
          console.log(error)
        })
    }
  },
  getters: {
    htmlReportConfiguration (state) {
      return state.htmlReportConfiguration
    },
    pdfReportConfiguration (state) {
      return state.pdfReportConfiguration
    },
    errorReportConfiguration (state) {
      return state.errorReportConfiguration
    }
  }
};