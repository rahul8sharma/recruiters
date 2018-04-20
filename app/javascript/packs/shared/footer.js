import Vue from 'vue/dist/vue.esm';

// This the .vue file that we will create next
import SharedFooterComponent from 'components/shared/Footer.vue';

const baseFooter = new Vue({
    el: '#shared-footer-component',
    components: {
        'shared-footer-component': SharedFooterComponent
    }
});