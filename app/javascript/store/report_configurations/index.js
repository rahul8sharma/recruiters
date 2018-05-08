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
          let selected_config = JSON.parse(response.data.selected);
          let config = JSON.parse(response.data.config);
          commit('setErrorReportConfiguration', response.data.error);
          commit('setHtmlReportConfiguration', deepMerge(config.html.sections,selected_config.html.sections));
          commit('setPdfReportConfiguration', deepMerge(config.pdf.sections,selected_config.pdf.sections));
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