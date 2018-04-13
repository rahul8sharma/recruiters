import Vue from 'vue/dist/vue.esm';
import Vuex from 'vuex/dist/vuex.esm';
import vueResource from 'vue-resource';
Vue.use(Vuex);
Vue.use(vueResource)

import vacstore  from './vac';

export const store = new Vuex.Store({
    modules: {
        vacstore: vacstore
    }
})