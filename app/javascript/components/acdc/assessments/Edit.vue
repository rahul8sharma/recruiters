<template>
  <div class="wrapper">
    <loader></loader>
    <div class="heading_bar flex-box container">
      <div class="fs-18 black-10">
        <div class="assessment_title bold">
          {{this.$store.state.AcdcStore.assessmentName}}
          <span class="fs-14 font-normal">(B-Hive with Co-Cubes)</span>
        </div>
        <em class="fs-14 black-7">AID: {{this.$store.state.AcdcStore.assessmentId}}, Status: In {{this.$store.state.AcdcStore.assessmentStatus}}</em>
      </div>
      <div class="spacer"></div>
      <button class="btn-link uppercase black-6 fs-14">Delete this Assessment</button>
      <button class="btn-warning inverse uppercase fs-14">Save &amp; Exit</button>
    </div>

    <div class="tab_view clearfix">
      <ul class="tab_list large-7 columns">
        <li class="tab_item " 
          v-for="(tab, index) in tabItems"
          v-bind:key="tab"
          v-bind:class="['done', { active: currentTab === tab }]"
          v-on:click="currentTab = tab">
          <div class="index">
            <div class="count">{{ index + 1 }}</div>
          </div> 
          <div class="line"></div>
          <div class="tab_name">
            <span>{{ tab }}</span>
          </div>
        </li>
      </ul>

      <div class="large-23 columns">

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
         
          <button class="button btn-warning uppercase fs-14">Save &amp; Next</button>
        </div>

        <component
          v-bind:is="currentTabComponent">
        </component>

      </div>

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

  export default {
    components: { Description, ConfigureTools,
                  CreateCustomForms, AddBehavioursCompetenciesTraits, 
                  SelectSubjectiveObjectiveQuestions, SelectTemplate,
                  ReportConfiguration, Review,
                  Loader },
    data () {
      return {
        currentTab: 'Description',
        tabItems: [
          'Description', 
          'Configure Tools',
          'Create Custom Forms',
          'Add Behaviours/ Competencies/ Traits',
          'Select Subjective/ Objective Questions',
          'Select Template',
          'Report Configuration',
          'Review'
        ]
      }
    },
    computed: {
      currentTabComponent: function () {
        return this.currentTab.replace(/\s+|[,\/]/g, '');
      }
    }
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
  
  .action_bar 
    height: $actionBarHeight
    display: -webkit-box
    display: -moz-box
    display: -ms-flexbox
    display: -webkit-flex
    display: flex
    align-items: center
    border-bottom: 2px solid rgba(0, 0, 0, 0.1)
    padding: 0 25px
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
  .edit_section
    height: calc(100vh - (#{$headerHeight} + #{$headingBarHeight} + #{$actionBarHeight} + 10px))
    padding: 20px
    overflow-y: auto
</style>