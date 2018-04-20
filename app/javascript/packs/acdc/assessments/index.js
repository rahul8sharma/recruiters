import Vue from 'vue/dist/vue.esm';
import VueResource from 'vue-resource';
import { store } from 'store'
import VueMixin from 'config/VueConfig'

// This the .vue file that we will create next
import AcdcAssessmentsIndexComponent from 'components/acdc/assessments/Index.vue';

Vue.use(VueResource);

var element = document.getElementById("acdc-assessments-index-component");

const index = new Vue({
    el: '#acdc-assessments-index-component',
    data: {
	    user_id: element.dataset.user_id,
	    company_id: element.dataset.company_id
     },
    store,
    components: {
        'acdc-assessments-index-component': AcdcAssessmentsIndexComponent
    }
});