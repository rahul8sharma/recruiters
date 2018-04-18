// Import external components
import Vue from 'vue/dist/vue.esm';
import Vuex from 'vuex/dist/vuex.esm';
import vueResource from 'vue-resource';

// Import Internal components
import AcdcStore  from './acdc';
import ReportConfigurationStore  from './report_configurations';

// Used external components
Vue.use(Vuex);
Vue.use(vueResource)

// Created instance of vuex
export const store = new Vuex.Store({
    modules: {
        AcdcStore: AcdcStore,
        ReportConfigurationStore: ReportConfigurationStore
    }
})