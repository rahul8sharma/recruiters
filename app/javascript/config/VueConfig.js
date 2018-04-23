import Vue from 'vue/dist/vue.esm';
import { CustomActions } from './api_url.js'

Vue.http.interceptors.push(function(request) {
  var element = document.getElementsByClassName("loaderContainer")[0]
  if(element != undefined) { element.classList.toggle("loaderOpen"); }

  return function(response) {
    if(element != undefined) { element.classList.toggle("loaderOpen"); }
  };
});

Vue.http.headers.common['X-CSRF-Token'] = document
  .querySelector('meta[name="csrf-token"]')
  .getAttribute('content')

const MappingUrl = {
  data() {
    return {
      get: {}
    }
  },
  created() {
    this.get = this.$resource('', {}, CustomActions);
  }
}
Vue.mixin({mixins: [MappingUrl]})
