import Vue from 'vue/dist/vue.esm';

// This the .vue file that we will create next
import AcdcAssessmentsIndexComponent from 'components/acdc/assessments/Index.vue';

const integrationIndex = new Vue({
    el: '#acdc-assessments-index-component',
    components: {
        'acdc-assessments-index-component': AcdcAssessmentsIndexComponent
    }
});