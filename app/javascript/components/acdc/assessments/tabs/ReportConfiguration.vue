<template>
  <div class="edit_section">
    <button @click="changeReportType()">Html Report</button>
    <button @click="changeReportType()">PDF Report</button>
    <v-jstree v-if="isHtmlReport" :data="htmlData" show-checkbox multiple allow-batch whole-row @item-click="itemClick"></v-jstree>
    <v-jstree v-if="!isHtmlReport" :data="pdfData" show-checkbox multiple allow-batch whole-row @item-click="itemClick"></v-jstree>
    <button @click="generateReportPreview()">Generate {{isHtmlReport ? "HTML" : "PDF"}} Preview</button>
    <iframe class="hide" id="reportConfigIframe" style="height: 1000px;width:99.7%;margin:auto;overflow:auto;"></iframe>
    <div class="divider-4"></div>
  </div>
</template>

<script>
  import VJstree from 'vue-jstree'
  export default {
    components: { VJstree },
    data () {
      return  {
        isHtmlReport: true
      }
    },
    methods: {
      // TODO: If item click event not needed then remove it
      itemClick (node) {
        console.log(node.model.text + ' clicked !')
      },
      changeReportType() {
        this.isHtmlReport = !this.isHtmlReport
        document.getElementById("reportConfigIframe").classList.add("hide");
      },
      generateReportPreview() {
        let cloneConfig = {}
        let selectedReportConfig = []
        if (this.isHtmlReport) {
          cloneConfig = JSON.parse(JSON.stringify(this.htmlData));
          selectedReportConfig = { html: { sections: getSelectedReportConfig(cloneConfig) } }
        } else {
          cloneConfig = JSON.parse(JSON.stringify(this.pdfData));
          selectedReportConfig = { pdf: { sections: getSelectedReportConfig(cloneConfig) } }
        }
        let viewMode = this.isHtmlReport ? "html" : "pdf"
        this.$store.dispatch('getreportPreview', {
          config: selectedReportConfig,
          viewMode: viewMode
        })
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
    },
    watch: {
      '$store.state.ReportConfigurationStore.reportPreview' (newCount, oldCount) {
        let reportPreviewConfig = this.$store.getters.reportPreview
        if (reportPreviewConfig.length != 0) {
          document.getElementById('reportConfigIframe').classList.remove("hide");
          document.getElementById('reportConfigIframe').contentWindow.document.body.innerHTML = reportPreviewConfig
        }
      }
    }
  }

  function getSelectedReportConfig(reportConfig) {
    for(var k=0; k<reportConfig.length; k++) {
      if (reportConfig[k].selected) {
        reportConfig[k]["state"] = { "selected": true}
        delete reportConfig[k].opened
        delete reportConfig[k].selected
        delete reportConfig[k].value
        if (typeof reportConfig[k] == "object" && reportConfig[k].children != null) {getSelectedReportConfig(reportConfig[k].children);
        }
      } else {
        reportConfig.splice(k, 1);
        k = k - 1;
      }
    };
    return reportConfig;
  }
</script>