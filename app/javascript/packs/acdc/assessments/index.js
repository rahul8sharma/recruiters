import Vue from 'vue/dist/vue.esm';
import VueResource from 'vue-resource';
import { store } from 'store'

// This the .vue file that we will create next
import AcdcAssessmentsIndexComponent from 'components/acdc/assessments/Index.vue';

Vue.use(VueResource);

const integrationIndex = new Vue({
    el: '#acdc-assessments-index-component',
    store,
    components: {
        'acdc-assessments-index-component': AcdcAssessmentsIndexComponent
    }
});