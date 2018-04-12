import Vue from 'vue/dist/vue.esm';

// This the .vue file that we will create next
import JitReloadedVacNewComponent from 'components/jit_reloaded/vac/new.vue';

const integrationIndex = new Vue({
    el: '#jit-reloaded-vac-new-component',
    components: {
        'jit-reloaded-vac-new-component': JitReloadedVacNewComponent
    }
});