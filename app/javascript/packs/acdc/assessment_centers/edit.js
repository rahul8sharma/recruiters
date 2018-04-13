import Vue from 'vue/dist/vue.esm';

// This the .vue file that we will create next
import AcdcAssessmentCentersEditComponent from 'components/acdc/assessment_centers/edit.vue';

const integrationIndex = new Vue({
    el: '#acdc-assessment-centers-edit-component',
    components: {
        'acdc-assessment-centers-edit-component': AcdcAssessmentCentersEditComponent
    }
});