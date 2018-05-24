<template>
  <div>
    <loader></loader>
    <div class="heading_bar flex-box container">
      <div class="fs-18 black-10">
        <div class="assessment_title bold">
          {{this.$store.state.AcdcStore.assessmentName}}
          <span class="fs-14 font-normal" v-if="$store.state.AcdcStore.assessmentRawData.tools != null">
            ({{splitToolsName($store.state.AcdcStore.assessmentRawData.tools)}})
          </span>
        </div>
        <em class="fs-14 black-7">ID: {{this.$store.state.AcdcStore.assessmentId}}, Status: {{isSendForReview ? 'Approval Pending' : 'In ' + this.$store.state.AcdcStore.assessmentStatus}}</em>
      </div>
      <div class="spacer"></div>
      <div v-if="!isSendForReview">
        <button
          class="btn-link uppercase black-6 fs-14"
          @click="setDeleteModalState"
        >
          Delete this Assessment
        </button>
        <!-- Popup for delete assessment. -->
        <Modal
          v-bind:isModalOpen="modal.isDeleteAssessmentModalOpen"
          v-bind:isButtonDisable="false"
          headerText="Delete Assessment"
          cancelText="CANCEL"
          confirmText="DELETE"
          :confirm-method="deleteAssessment"
          :set-modal-state="setDeleteModalState"
        >
          <DeleteAssessment></DeleteAssessment>
        </Modal>
        <button
          class="btn-warning inverse uppercase fs-14"
          @click="saveAndExit"
        >
          Save &amp; Exit
        </button>
      </div>
      <div v-else="isSendForReview">
        <div v-if="$store.state.AcdcStore.canApprove">
          <button 
            class="btn-link uppercase black-6 fs-14"
            @click="setDisapproveModalState"
          >
            DISAPPROVE
          </button>
          <DisapproveModal
            v-bind:isDisapproveModalOpen="modal.isDisapproveModalOpen"
            :set-disapprove-modal-state="setDisapproveModalState"
          >
          </DisapproveModal>
          <button 
            class="btn-warning inverse uppercase fs-14"
            @click="setApproveModalState"
          >
            APPROVE
          </button>
          <!-- Popup for approve assessment. -->
          <Modal
            v-bind:isModalOpen="modal.isApproveModalOpen"
            v-bind:isButtonDisable="false"
            headerText="Approve this Assessment"
            cancelText="CANCEL"
            confirmText="APPROVE"
            :confirm-method="approve"
            :set-modal-state="setApproveModalState"
          >
            <ApproveAssessment></ApproveAssessment>
          </Modal>
        </div>
        <div v-else="!$store.state.AcdcStore.canApprove">
          <em class="fs-14 black-7">You can’t take any action until this Assessment is not Approved.</em>
        </div>
      </div>
    </div>

    <div class="tab_view clearfix" v-if="!isSendForReview">
      <ul class="tab_list large-7 columns p-0">
        <li class="tab_item " 
          v-for="(tab, index) in tabItems"
          v-bind:key="tab.text"
          v-bind:class="[{ done: isTabValid(tab.url) }, { active: currentTab === tab.text }, {inActive: !isTabValid(tab.url)}]"
          v-on:click="tabHandler(tab.text, index + 1, isTabValid(tab.url))">
          <div class="index">
            <div class="count">{{ index + 1 }}</div>
          </div> 
          <div class="line"></div>
          <div class="tab_name">
            <span>{{ tab.text }}</span>
          </div>
        </li>
      </ul>

      <div class="large-23 columns p-0">
        <component
          v-bind:tabData="currentTabData"
          v-bind:isSendForReview="isSendForReview"
          v-bind:is="currentTabComponent"
        >
        </component>

      </div>

    </div>

    <div v-else="!isSendForReview">
      <Review
        v-bind:isSendForReview="isSendForReview"
      ></Review>
    </div>
  </div>  
</template>

<script>
  import Description from 'components/acdc/assessments/tabs/Description.vue';
  import ConfigureTools from 'components/acdc/assessments/tabs/ConfigureTools.vue';
  import CreateCustomForms from 'components/acdc/assessments/tabs/CreateCustomForms.vue';
  import AddBehavioursCompetenciesTraits from 'components/acdc/assessments/tabs/AddBehavioursCompetenciesTraits.vue';
  import SelectSubjectiveObjectiveQuestions from 'components/acdc/assessments/tabs/SelectSubjectiveObjectiveQuestions.vue';
  import SelectTemplate from 'components/acdc/assessments/tabs/SelectTemplate.vue';
  import ReportConfiguration from 'components/acdc/assessments/tabs/ReportConfiguration.vue';
  import Review from 'components/acdc/assessments/tabs/Review.vue';
  import Loader from 'components/shared/loader.vue';
  import ToolsJson from 'config/tools.json'
  import assessmentHelper from 'helpers/assessment.js'
  import validationHelper from 'helpers/validation.js'
  import Modal from 'components/shared/modal.vue';
  import DeleteAssessment from 'components/acdc/assessments/tabs/actions/Delete.vue';
  import ApproveAssessment from 'components/acdc/assessments/tabs/actions/Approve.vue';
  import DisapproveModal from 'components/acdc/assessments/tabs/actions/Disapprove.vue';
  import assessmentUrlHelper from 'helpers/assessmentUrl.js'

  export default {
    components: { 
      Description, ConfigureTools, CreateCustomForms, AddBehavioursCompetenciesTraits,
      SelectSubjectiveObjectiveQuestions, SelectTemplate, ReportConfiguration, Review,
      Loader, DisapproveModal, Modal, DeleteAssessment, ApproveAssessment 
    },
    data () {
      return {
        currentTab: 'Description',
        currentTabIndex: 0,
        tabItems: [
          {
            text: 'Description', url: 'description',
            tabData: { name: this.$store.state.AcdcStore.assessmentName, raw_data: {} }
          },
          {
            text: 'Configure Tools',
            url: 'tool_configuaration',
            tabData: { raw_data: [], tools: [] }
          },
          {
            text: 'Create Custom Forms',
            url: 'create_custom_forms',
            tabData: { raw_data: {} }
          },
          {
            text: 'Add Behaviours/ Competencies/ Traits',
            url: 'add_behaviours_competencies_traits',
            tabData: { raw_data: {} }
          },
          {
            text: 'Select Subjective/ Objective Questions',
            url: 'select_subjective_objective_questions',
            tabData: { raw_data: {} }
          },
          {
            text: 'Select Template',
            url: 'select_template',
            tabData: { raw_data: {} }
          },
          {
            text: 'Report Configuration', url: 'report_configuration',
            tabData: { raw_data: {} }
          },
          {
            text: 'Review',
            url: 'review',
            tabData: { raw_data: {} }
          }
        ],
        modal: {
          isDeleteAssessmentModalOpen: false,
          isApproveModalOpen: false,
          isDisapproveModalOpen: false
        }
      }
    },
    computed: {
      currentTabComponent: function () {
        window.location.href = window.location.href.split('#')[0] + '#' +
          getUrlByText(this.currentTab, this.tabItems);
        return this.currentTab.replace(/\s+|[,\/]/g, '');
      },
      currentTabData: function () {
        return getDataByText(this.currentTab, this.tabItems);
      },
      isSendForReview:function() {
        return this.$store.state.AcdcStore.assessmentStatus === 'review'
      }
    },
    methods: {
      setCurrentTab:function(text){
        this.currentTab = text
      },
      setCurrentTabIndex:function(index){
        this.currentTabIndex = index
      },
      tabHandler:function(text, index, isValid){
        if(isValid) {
          this.setCurrentTab(text);
          this.setCurrentTabIndex(index);
        }
      },
      saveAndExit:function(){
        window.location = "/companies/" + this.$store.state.AcdcStore.companyId + "/acdc"
      },
      deleteAssessment:function(){
        this.$store.dispatch('deleteAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId
        });
      },
      splitToolsName(tools) {
        return assessmentHelper.splitToolsName(tools)
      },
      isTabValid(tab_url) {
        if(Object.keys(this.$store.state.AcdcStore.assessmentTabSaved).length !== 0) {
          return validationHelper.isTabValid(this.$store.state.AcdcStore.assessmentTabSaved, tab_url)
        } else {
          return false
        }
      },
      setApproveModalState () {
        this.modal.isApproveModalOpen = !this.modal.isApproveModalOpen
      },
      setDisapproveModalState () {
        this.modal.isDisapproveModalOpen = !this.modal.isDisapproveModalOpen
      },
      setDeleteModalState () {
        this.modal.isDeleteAssessmentModalOpen = !this.modal.isDeleteAssessmentModalOpen
      },
      approve:function(){
        this.$store.dispatch('updateAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          acdc_assessment: {
            reviewer_id: this.$store.state.AcdcStore.userId,
            status: 'approve'
          }
        }).then(() => {
          window.location = assessmentUrlHelper.getAssessmentUrl(this.$store.state.AcdcStore.companyId)
        })
      }
    },
    created: function () {
      let urlLength = window.location.href.split('#').length;
      if (urlLength > 1) {
        let tab = getTextByUrl(window.location.href.split('#')[urlLength - 1], this.tabItems);
        this.tabHandler(tab.text, tab.index, true)
      }
    },
    beforeMount() {
      this.$store.dispatch('setAssessmentRawData', {raw_data: {}})
      this.$store.dispatch('getAcdcAssessment', {
        assessmentId: this.$store.state.AcdcStore.assessmentId,
        companyId: this.$store.state.AcdcStore.companyId
      })
    },
    watch: {
      '$store.state.AcdcStore.assessmentRawData' (newCount, oldCount) {
        let rawData = this.$store.state.AcdcStore.assessmentRawData
        if(Object.keys(rawData).length != 0) {
          var i, len = this.tabItems.length
          for (i = 0; i < len; i++) {
            if (this.tabItems[i].url == 'tool_configuaration') {
              if(rawData[this.tabItems[i].url].length == 0) {
                var j, toolLen = rawData['tools'].length
                this.tabItems[i].tabData.raw_data = []
                for (j = 0; j < toolLen; j++) {
                  this.tabItems[i].tabData.raw_data.push(ToolsJson[rawData['tools'][j]])
                }
              } else {
                this.tabItems[i].tabData.raw_data = rawData[this.tabItems[i].url]
              }
              this.tabItems[i].tabData.tools = rawData['tools']
            } else {
              this.tabItems[i].tabData.raw_data = rawData[this.tabItems[i].url]
            }
          }
        }
      },
      '$store.state.AcdcStore.assessmentCurrentTab' (newCount, oldCount) {
        let tab = getNextTab(this.currentTab, this.tabItems)
        this.tabHandler(tab.text, tab.index, true)
      },
      '$store.state.AcdcStore.changeCurrentTab' (newCount, oldCount) {
        let tab = this.$store.state.AcdcStore.changeCurrentTab
        this.tabHandler(tab.text, tab.index, true)
      }
    }
  }

  function getUrlByText(text, data) {
    var i, len = data.length;
    for (i = 0; i < len; i++) {
      if (data[i] && (data[i].text == text)) {
        return data[i]['url'];
      }
    }
  }

  function getTextByUrl(url, data) {
    var i, len = data.length;
    for (i = 0; i < len; i++) {
      if (data[i] && (data[i].url == url)) {
        return {
          text: data[i]['text'],
          index: i
        };
      }
    }
  }

  function getDataByText(text, data) {
    var i, len = data.length;
    for (i = 0; i < len; i++) {
      if (data[i] && (data[i].text == text)) {
        return data[i]['tabData'];
      }
    }
  }

  function getNextTab(text, data) {
    var i, len = data.length;
    for (i = 0; i < len; i++) {
      if (data[i] && (data[i].text == text)) {
        if (data[i]['text'] == 'Review') {
          return {
            text: data[i]['text'],
            index: i + 1
          };
        } else {
          return {
            text: data[i+1]['text'],
            index: i + 2
          };
        }
      }
    }
  }
  
  function createAcdcAssessmentJson(tabItems) {
    var i, len = tabItems.length;
    var acdcAssessmentJson = {}
    for (i = 0; i < len; i++) {
      if (tabItems[i].tabData.hasOwnProperty('tools')) {
        acdcAssessmentJson['tools'] = tabItems[i].tabData.tools
      }
      acdcAssessmentJson[tabItems[i].url] = tabItems[i].tabData.raw_data
    }
    return {raw_data: acdcAssessmentJson, name: tabItems[0].tabData.name}
  }
</script>

<style lang="sass" scoped>
  $headerHeight: 55px
  $headingBarHeight: 80px
  $actionBarHeight: 50px
  $color-warning: #ff8308
  $color-gray: #eaeaea
  
  .heading_bar
    height: $headingBarHeight
  .tab_view
    border-top: 2px solid rgba(0, 0, 0, 0.1)
    height: calc(100vh - (#{$headerHeight} + #{$headingBarHeight} + 6px))
  .tab_list
    height: 100%
    overflow-y: auto
    background: #f6f6f6
    border-right: 2px solid rgba(0, 0, 0, 0.1)
    .tab_item
      position: relative
      padding-left: 50px
      color: rgba(0, 0, 0, 0.9)
      border-left: 4px solid transparent
      cursor: pointer
      .index
        position: absolute
        left: 12px
        top: 50%
        transform: translateY(-50%)
        width: 24px
        height: 24px
        background-color: $color-gray
        border-radius: 50%
        line-height: 24px
        text-align: center
        .count
          font-size: 14px
      .line
        width: 2px
        height: 32px
        background-color: $color-gray
        position: absolute
        top: -16px
        left: 24px
      .tab_name
        height: 60px
        display: -webkit-box
        display: -moz-box
        display: -ms-flexbox
        display: -webkit-flex
        display: flex
        align-items: center
        border-bottom: 2px solid $color-gray
      &:hover
        opacity: 0.5
      &:first-child
        .line
          display: none
      &.active
        border-left-color: $color-warning
        background: #fff
        .tab_name
          color: $color-warning
      &.inActive
        cursor: not-allowed
        &:hover
          background: transparent
          border-color: transparent
          cursor: not-allowed
          opacity: 1
      &.done
        .index
          background: url('~assets/images/ic-checked.svg') no-repeat 0 0
          .count
            display: none
        .line
        .tab_name
        &.active
          .index
            background: url('~assets/images/ic-checked.svg') no-repeat 0 0
</style>
<style lang="sass">
  .edit_section
    height: calc(100vh - (55px + 80px + 50px + 10px))
    padding: 20px
    overflow-y: auto
  .action_bar 
    height: 50px
    display: -webkit-box
    display: -moz-box
    display: -ms-flexbox
    display: -webkit-flex
    display: flex
    align-items: center
    border-bottom: 2px solid rgba(0, 0, 0, 0.1)
    padding: 0 25px
    .link_breadcrumb
      a
        color: #000
        padding: 10px 20px
        background: url('~assets/images/patch-break.svg') no-repeat 0 center
        &:first-child
          background: none

        &:hover
          opacity: 0.6
        &.active
          color: #ff8308
          text-shadow: 1px 0 0 #ff8308
        
    .info_tooltip
      width: 24px
      height: 24px
      position: relative
      margin-right: 20px
      background: url('~assets/images/ic-info.svg') no-repeat 0 0
      cursor: pointer
      .tooltip_text
        position: absolute
        top: calc(100% + 20px)
        left: 50%
        width: 200px
        transform: translateX(-50%)
        display: none
        z-index: 5
        .text_container
          position: relative
          padding: 10px
          border-radius: 10px
          background: #606062
          color: #fff
          font-size: 12px
          box-shadow: 0 2px 5px 0 rgba(0, 0, 0, 0.26), 0 2px 10px 0 rgba(0, 0, 0, 0.16)
          &:after
            bottom: 100%
            left: 50%
            border: solid transparent
            content: " "
            height: 0
            width: 0
            position: absolute
            pointer-events: none
            border-color: rgba(96, 96, 98, 0)
            border-bottom-color: #606062
            border-width: 10px
            margin-left: -10px
      &:hover
        .tooltip_text
          display: block
</style>