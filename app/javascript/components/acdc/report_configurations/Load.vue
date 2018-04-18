<template>
  <div>
    <v-jstree :data="htmlData" show-checkbox multiple allow-batch whole-row @item-click="itemClick"></v-jstree>
  </div>
</template>

<script>
  import VJstree from 'vue-jstree'
  export default {
    components: { VJstree },
    methods: {
      // TODO: If item click event not needed then remove it
      itemClick (node) {
        console.log(node.model.text + ' clicked !')
      }
    },
    created: function () {
      // Fetched report data
      this.$store.dispatch('getReportConfiguration')
    },
    computed: {
      htmlData () {
        return this.$store.getters.htmlReportConfiguration
      },
      pdfData () {
        return this.$store.getters.pdfReportConfiguration
      },
      error () {
        return this.$store.getters.errorReportConfiguration
      }
    }
  }
</script>