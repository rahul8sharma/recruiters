import Vue from 'vue/dist/vue.esm';
import Vuex from 'vuex/dist/vuex.esm';
import vueResource from 'vue-resource';
Vue.use(Vuex);
Vue.use(vueResource)

import AcdcStore  from './acdc';
import ReportConfigurationStore  from './report_configurations';

export const store = new Vuex.Store({
    modules: {
        AcdcStore: AcdcStore,
        ReportConfigurationStore: ReportConfigurationStore
    }
})