import Vue from 'vue/dist/vue.esm';

export default {
  state: {
    htmlReportConfiguration: [],
    pdfReportConfiguration: [],
    errorReportConfiguration: [],
    reportPreview: ""
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
    },
    setReportPreview (state, payload) {
      state.reportPreview = payload
    }
  },
  actions: {
    getReportConfiguration ({commit, getters}, payload) {
      let reportConfiguration = []
      Vue.http.get('/report_configurations/load_configuration/?report_type=suitability&assessment_type=fit&company_id=2')
        .then(function (response) {
          let selected_config = JSON.parse(response.data.selected);
          let config = JSON.parse(response.data.config);
          commit('setErrorReportConfiguration', response.data.error);
          commit('setHtmlReportConfiguration', deepMerge(config.html.sections,selected_config.html.sections));
          commit('setPdfReportConfiguration', deepMerge(config.pdf.sections,selected_config.pdf.sections));
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
    htmlReportConfiguration (state) {
      return state.htmlReportConfiguration
    },
    pdfReportConfiguration (state) {
      return state.pdfReportConfiguration
    },
    errorReportConfiguration (state) {
      return state.errorReportConfiguration
    },
    reportPreview (state) {
      return state.reportPreview
    }
  }
};


// Javascript code for deep merge of two array json.

var found = false;

function deepMerge(target, selected) {
  target.forEach( function (targetedItem) {
    found = false;
    var selectedItem = getObjectBykey(selected, targetedItem.id)
    if (selectedItem) {
      targetedItem['opened'] = true
      targetedItem['selected'] = true
    } else {
      targetedItem['opened'] = false
      targetedItem['selected'] = false
    }
    targetedItem['value'] = targetedItem.text
    if (typeof targetedItem == "object" && targetedItem.children != null) {
      deepMerge(targetedItem.children, selected);
    }
  });
  return target;
}

function getObjectBykey(jsonObjects, id) {
  jsonObjects.forEach( function (jsonObject) {
    if(jsonObject.id === id) {
      found = true;
    } else if (typeof jsonObject == "object" && jsonObject.children != null && !found) {
      getObjectBykey(jsonObject.children, id);
    }
  });
  return found;
}