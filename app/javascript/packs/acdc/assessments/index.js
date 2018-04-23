import Vue from 'vue/dist/vue.esm';
import VueResource from 'vue-resource';
import { store } from 'store'
import VueMixin from 'config/VueConfig.js'

// This the .vue file that we will create next
import AcdcAssessmentsIndexComponent from 'components/acdc/assessments/Index.vue';

Vue.use(VueResource);

const index = new Vue({
  el: '#acdc-assessments-index-component',
  store,
  components: {
    'acdc-assessments-index-component': AcdcAssessmentsIndexComponent
  },
  created: function () {
    // Get company and user id from rails view
    var element = document.getElementById("acdc-assessments-index-component");

    // Set company and user id to vuex
    store.dispatch("setUserId", {user_id: element.dataset.user_id});
    store.dispatch("setCompanyId", {company_id: element.dataset.company_id});
  }
});