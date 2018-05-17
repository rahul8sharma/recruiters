<template>
  <div>
    <div class="action_bar">
      <div class="fs-16 black-9 link_breadcrumb uppercase">
        <a @click="changeToHtml()" v-bind:class="{active:isHtmlReport}">HTML</a>
        <a @click="changeToPdf()" v-bind:class="{active:!isHtmlReport}">PDF</a>
      </div>

      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos necessitatibus, facilis dolorum, impedit fugit voluptatibus nemo unde ut a dolore vero quo sint perspiciatis. Exercitationem saepe cum a vitae! Eligendi.
          </div>
        </div>
      </div>
     
      <button class="button btn-warning uppercase fs-14" @click="saveAndNext">
        Save &amp; Next
      </button>
    </div>
    
    <div class="edit_section">
      <v-jstree :data="isHtmlReport ? htmlData : pdfData" show-checkbox multiple allow-batch whole-row @item-click="itemClick"></v-jstree>
      <button @click="generateReportPreview()">Generate {{isHtmlReport ? "HTML" : "PDF"}} Preview</button>
      <iframe class="hide" id="reportConfigIframe" style="height: 1000px;width:99.7%;margin:auto;overflow:auto;"></iframe>
      <div class="divider-4"></div>
    </div>
  </div>

</template>

<script>
  import VJstree from 'vue-jstree'
  import deepConfigHelper from 'helpers/deepMerge.js'

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
      changeToHtml() {
        this.isHtmlReport = true
        document.getElementById("reportConfigIframe").classList.add("hide");
      },
      changeToPdf() {
        this.isHtmlReport = false
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
        this.tabData.raw_data.html = { sections: deepConfigHelper.getSelectedReportConfig(cloneConfig) }
      },
      setPdfRawData () {
        let cloneConfig = JSON.parse(JSON.stringify(this.pdfData));
        this.tabData.raw_data.pdf = { sections: deepConfigHelper.getSelectedReportConfig(cloneConfig) }
      },
      saveAndNext() {
        this.$store.dispatch('updateAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          acdc_assessment: {report_configuration: this.tabData.raw_data}
        })
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
          this.htmlData =  deepConfigHelper.deepMerge(
            this.$store.getters.htmlConfig,
            this.tabData.raw_data.html.sections
          )
        } else {
          this.htmlData =  deepConfigHelper.deepMerge(
            this.$store.getters.htmlConfig,
            this.$store.getters.htmlSelectedConfig
          )
        }
      },
      '$store.state.ReportConfigurationStore.pdfSelectedConfig' (newCount, oldCount) {
        if (this.tabData.raw_data.pdf.length != 0) {
          this.pdfData =  deepConfigHelper.deepMerge(
            this.$store.getters.pdfConfig,
            this.tabData.raw_data.pdf.sections
          )
        } else {
          this.pdfData =  deepConfigHelper.deepMerge(
            this.$store.getters.pdfConfig,
            this.$store.getters.pdfSelectedConfig
          )
        }
      }
    }
  }
</script>
<style lang="sass" scoped>
  .action_bar 
    .link_breadcrumb
      a
        padding: 5px 24px
        background: none
        position: relative
        &:first-child
          border-right: 2px solid #eaeaea
          padding-left: 0
</style>