import Vue from 'vue/dist/vue.esm';

export default {
  state: {
    htmlSelectedConfig: [],
    pdfSelectedConfig: [],
    errorReportConfiguration: [],
    reportPreview: "",
    htmlConfig: {},
    pdfConfig: {}
  },
  mutations: {
    sethtmlSelectedConfig (state, payload) {
      state.htmlSelectedConfig = payload
    },
    setpdfSelectedConfig (state, payload) {
      state.pdfSelectedConfig = payload
    },
    setErrorReportConfiguration (state, payload) {
      state.errorReportConfiguration = payload
    },
    setReportPreview (state, payload) {
      state.reportPreview = payload
    },
    setHtmlConfig (state, payload) {
      state.htmlConfig = payload
    },
    setPdfConfig (state, payload) {
      state.pdfConfig = payload
    }
  },
  actions: {
    getReportConfiguration ({commit, getters}, payload) {
      let reportConfiguration = []
      Vue.http.get('/report_configurations/load_configuration/?report_type=suitability&assessment_type=fit&company_id=2')
        .then(function (response) {
          let selected_config = JSON.parse(response.data.selected);
          let config = JSON.parse(response.data.config);
          commit('setHtmlConfig', config.html.sections);
          commit('setPdfConfig', config.pdf.sections);
          commit('sethtmlSelectedConfig', selected_config.html.sections);
          commit('setpdfSelectedConfig', selected_config.pdf.sections);
          commit('setErrorReportConfiguration', response.data.error);
        })
        .catch(error => {
          console.log(error)
        })
    },
    getreportPreview ({commit, getters}, payload) {
      let uri = "view_mode="+payload.viewMode;
      uri += "&assessment_type="+"fit";
      uri += "&report_type="+"suitability";
      uri += "&company_id="+"2";
      uri += "&candidate_type="+"employed";
      uri += "&custom_message="+"";
      uri += "&brand_partners="+"";
      
      let url = "/report_configurations/report_preview_"+"suitability"+"/?"+uri;

      Vue.http.post(url, { config: JSON.stringify(payload.config) })
        .then(function (response) {
          return response.json()
        })
        .then(function (response) {
          commit('setReportPreview', response.content);
        })
        .catch(error => {
          console.log(error)
        })
    }
  },
  getters: {
    htmlSelectedConfig (state) {
      return state.htmlSelectedConfig
    },
    pdfSelectedConfig (state) {
      return state.pdfSelectedConfig
    },
    errorReportConfiguration (state) {
      return state.errorReportConfiguration
    },
    reportPreview (state) {
      return state.reportPreview
    },
    htmlConfig (state) {
      return state.htmlConfig
    },
    pdfConfig (state) {
      return state.pdfConfig
    }
  }
};