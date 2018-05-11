<template>
  <div>
    <div class="action_bar">
      <div class="fs-16 black-9 bold">Follow these steps to configure every tool</div>

      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos necessitatibus, facilis dolorum, impedit fugit voluptatibus nemo unde ut a dolore vero quo sint perspiciatis. Exercitationem saepe cum a vitae! Eligendi.
          </div>
        </div>
      </div>
     
      <button class="button btn-warning uppercase fs-14">
        Save &amp; Next
      </button>
    </div>
    
    <div class="edit_section">
      <button @click="changeReportType()">Html Report</button>
      <button @click="changeReportType()">PDF Report</button>
      <v-jstree v-if="isHtmlReport" :data="htmlData" show-checkbox multiple allow-batch whole-row @item-click="itemClick"></v-jstree>
      <v-jstree v-if="!isHtmlReport" :data="pdfData" show-checkbox multiple allow-batch whole-row @item-click="itemClick"></v-jstree>
      <button @click="generateReportPreview()">Generate {{isHtmlReport ? "HTML" : "PDF"}} Preview</button>
      <iframe class="hide" id="reportConfigIframe" style="height: 1000px;width:99.7%;margin:auto;overflow:auto;"></iframe>
      <div class="divider-4"></div>
    </div>
  </div>

</template>

<script>
  import VJstree from 'vue-jstree'
  import deepConfig from 'config/deepMerge.js'

  export default {
    props: ['tabData'],
    components: { VJstree },
    data () {
      return  {
        isHtmlReport: true,
        htmlData: [],
        pdfData: []
      }
    },
    methods: {
      // TODO: If item click event not needed then remove it
      itemClick (node) {
        if (this.isHtmlReport) {
          this.setHtmlRawData()
        } else {
          this.setPdfRawData()
        }
      },
      changeReportType() {
        this.isHtmlReport = !this.isHtmlReport
        document.getElementById("reportConfigIframe").classList.add("hide");
      },
      generateReportPreview() {
        let selectedReportConfig = []
        if (this.isHtmlReport) {
          selectedReportConfig = { html: this.tabData.raw_data.html }
        } else {
          selectedReportConfig = { pdf: this.tabData.raw_data.pdf }
        }
        let viewMode = this.isHtmlReport ? "html" : "pdf"
        this.$store.dispatch('getreportPreview', {
          config: selectedReportConfig,
          viewMode: viewMode
        })
      },
      setHtmlRawData () {
        let cloneConfig = JSON.parse(JSON.stringify(this.htmlData));
        this.tabData.raw_data.html = { sections: deepConfig.getSelectedReportConfig(cloneConfig) }
      },
      setPdfRawData () {
        let cloneConfig = JSON.parse(JSON.stringify(this.pdfData));
        this.tabData.raw_data.pdf = { sections: deepConfig.getSelectedReportConfig(cloneConfig) }
      }
    },
    created: function () {
      // Fetched report data
      this.$store.dispatch('getReportConfiguration')
    },
    computed: {
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
      },
      'htmlData' (newCount, oldCount) {
        this.setHtmlRawData()
      },
      'pdfData' (newCount, oldCount) {
        this.setPdfRawData()
      },
      '$store.state.ReportConfigurationStore.htmlSelectedConfig' (newCount, oldCount) {
        if (this.tabData.raw_data.html.length != 0) {
          this.htmlData =  deepConfig.deepMerge(
            this.$store.getters.htmlConfig,
            this.tabData.raw_data.html.sections
          )
        } else {
          this.htmlData =  deepConfig.deepMerge(
            this.$store.getters.htmlConfig,
            this.$store.getters.htmlSelectedConfig
          )
        }
      },
      '$store.state.ReportConfigurationStore.pdfSelectedConfig' (newCount, oldCount) {
        if (this.tabData.raw_data.pdf.length != 0) {
          this.pdfData =  deepConfig.deepMerge(
            this.$store.getters.pdfConfig,
            this.tabData.raw_data.pdf.sections
          )
        } else {
          this.pdfData =  deepConfig.deepMerge(
            this.$store.getters.pdfConfig,
            this.$store.getters.pdfSelectedConfig
          )
        }
      }
    }
  }
</script>