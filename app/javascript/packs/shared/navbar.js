import Vue from 'vue/dist/vue.esm';
import VueResource from 'vue-resource';
import { store } from 'store'
import VueMixin from 'config/VueConfig.js'

// This the .vue file that we will create next
import SharedNavbarComponent from 'components/shared/Navbar.vue';

Vue.use(VueResource);

const baseNavbar = new Vue({
  el: '#shared-navbar-component',
	store,
  components: {
    'shared-navbar-component': SharedNavbarComponent
  },
  created: function () {
    // Get company and user id from rails view
    var element = document.getElementById("shared-navbar-component");

    // Set company and user id to vuex
    store.dispatch("setUserId", {user_id: element.dataset.user_id});
    store.dispatch("setCompanyId", {company_id: element.dataset.company_id});
    store.dispatch("setCanCreate", {can_create: element.dataset.can_create});
    store.dispatch("setCanApprove", {can_approve: element.dataset.can_approve});
  }
});