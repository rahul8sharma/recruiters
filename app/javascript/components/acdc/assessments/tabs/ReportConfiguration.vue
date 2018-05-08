<template>
	<div class="edit_section">
		<button @click="changeReportType()">Html Report</button>
		<button @click="changeReportType()">PDF Report</button>
		<v-jstree v-if="isPdfReport" :data="htmlData" show-checkbox multiple allow-batch whole-row @item-click="itemClick"></v-jstree>
		<v-jstree v-if="!isPdfReport" :data="pdfData" show-checkbox multiple allow-batch whole-row @item-click="itemClick"></v-jstree>
	<div class="divider-4"></div>
	</div>
</template>

<script>
  import VJstree from 'vue-jstree'
  export default {
    components: { VJstree },
    data () {
      return  {
        isPdfReport: true
      }
    },
    methods: {
      // TODO: If item click event not needed then remove it
      itemClick (node) {
        console.log(node.model.text + ' clicked !')
      },
      changeReportType() {
        this.isPdfReport = !this.isPdfReport
      }
    },
    created: function () {
      // Fetched report data
      this.$store.dispatch('getReportConfiguration')
    },
    computed: {
      htmlData () {
       return this.$store.getters.htmlReportConfiguration;
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