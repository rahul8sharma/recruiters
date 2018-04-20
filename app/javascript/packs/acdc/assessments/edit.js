import Vue from 'vue/dist/vue.esm';
import VueResource from 'vue-resource';
import { store } from 'store'
import VueMixin from 'config/VueConfig'

// This the .vue file that we will create next
import AcdcAssessmentsEditComponent from 'components/acdc/assessments/Edit.vue';

Vue.use(VueResource);

const edit = new Vue({
    el: '#acdc-assessments-edit-component',
    store,
    components: {
        'acdc-assessments-edit-component': AcdcAssessmentsEditComponent
    }
});

// Get company, assessment and user id from rails view
var element = document.getElementById("acdc-assessments-edit-component");

// Set company, assessment and user id to vuex
store.dispatch("setUserId", {user_id: element.dataset.user_id});
store.dispatch("setCompanyId", {company_id: element.dataset.company_id});
store.dispatch("setAssessmentId", {assessment_id: element.dataset.assessment_id});