import Vue from 'vue/dist/vue.esm';
import VueMixin from 'config/VueConfig'

// This the .vue file that we will create next
import AcdcAssessmentsEditComponent from 'components/acdc/assessments/Edit.vue';

const edit = new Vue({
    el: '#acdc-assessments-edit-component',
    components: {
        'acdc-assessments-edit-component': AcdcAssessmentsEditComponent
    }
});