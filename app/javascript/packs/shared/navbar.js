import Vue from 'vue/dist/vue.esm';

// This the .vue file that we will create next
import SharedNavbarComponent from 'components/shared/Navbar.vue';

const baseNavbar = new Vue({
    el: '#shared-navbar-component',
    components: {
        'shared-navbar-component': SharedNavbarComponent
    }
});