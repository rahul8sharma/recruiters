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
    
    <div class="edit_section p-0">
      <div class="p-24">
        <v-jstree :data="isHtmlReport ? htmlData : pdfData" show-checkbox multiple allow-batch whole-row @item-click="itemClick"></v-jstree>
      </div>  
      <div class="action_bar generate_action">
        <div class="spacer"></div>
        <button class="btn-warning inverse uppercase fs-14" @click="generateReportPreview()">Generate {{isHtmlReport ? "HTML" : "PDF"}} Preview</button>
        
      </div>

      <div class="report_config_preview hide" id="reportConfigPreview">
        <div class="heading fs-14 uppercase">
          <div class="spacer"></div> 
          <strong>{{isHtmlReport ? "HTML" : "PDF"}} Preview</strong> 
          <div class="spacer"></div> 
          <div class="close" @click="closePreview()">&times;</div>
        </div>
          
        <iframe id="reportConfigIframe"></iframe>
        <div class="divider-4"></div>

      </div>
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
      closePreview() {
        document.getElementById("reportConfigPreview").classList.add("hide");
      },
      changeToHtml() {
        this.isHtmlReport = true
        document.getElementById("reportConfigPreview").classList.add("hide");
      },
      changeToPdf() {
        this.isHtmlReport = false
        document.getElementById("reportConfigPreview").classList.add("hide");
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
          document.getElementById('reportConfigPreview').classList.remove("hide");
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
<style lang="sass" scoped>
  iframe
    width: 100%
    margin: auto
    overflow: auto
    border: 0 none
    padding: 0
    min-height: 100vh
    padding-bottom: 65px
  .report_config_preview
    position: fixed
    width: 100vw
    top: 0
    left: 0
    z-index: 999999
    background: #fff
    .heading
      background: #f6f6f6
      padding: 7px 14px 7px 25px
      display: -webkit-box
      display: -ms-flexbox
      display: flex
      -webkit-box-align: center
      -ms-flex-align: center
      align-items: center
    .close
      font-size: 30px
      color: #000
      cursor: pointer
      &:hover
        opacity: 0.5
  .action_bar
    &.generate_action
      border-top: 2px solid rgba(0, 0, 0, 0.1)
    .link_breadcrumb
      a
        padding: 5px 24px
        background: none
        position: relative
        &:first-child
          border-right: 2px solid #eaeaea
          padding-left: 0
</style>