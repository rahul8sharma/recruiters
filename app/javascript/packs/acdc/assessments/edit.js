import Vue from 'vue/dist/vue.esm';

// This the .vue file that we will create next
import AcdcAssessmentsEditComponent from 'components/acdc/assessments/Edit.vue';

const integrationIndex = new Vue({
    el: '#acdc-assessments-edit-component',
    components: {
        'acdc-assessments-edit-component': AcdcAssessmentsEditComponent
    }
});