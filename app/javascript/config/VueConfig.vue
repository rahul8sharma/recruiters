<script type="text/javascript">
  import Vue from 'vue/dist/vue.esm';
  import { CustomActions } from './api_url.js'

  Vue.http.interceptors.push(function(request) {
    document.getElementById("loader").classList.add("loaderOpen");

    return function(response) {
      document.getElementById("loader").classList.remove("loaderOpen");
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
</script>