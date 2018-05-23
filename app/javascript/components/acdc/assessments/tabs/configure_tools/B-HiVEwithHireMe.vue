<template>
  <div>
    <div class="section_title uppercase fs-12 bold">
      {{index}}. B-HiVE with HireMe
    </div>

    <div class="p-15">
      <div class="large-12 pt-12">
        <em class="fs-12 black-6">(Hire.Me is an integrated recruitment solution that uniquely addresses the complex challenges HR professionals face when recruiting talent. The platform gives you the ability to effectively reach, engage and evaluate candidates on multiple parameters. Real-time assessment, analytics, and reporting help you make the best candidate hiring and selection decision.)</em>
      </div>
      <div class="divider-1"></div>
      
      <div class="clearfix">
        <div class="fs-16 black-9 uppercase large-16 columns">Show Sectional Score  </div>
        <div class="toggleSwitch large-14 columns">
          <label class="toggle">
            <input v-model="configureToolData.is_sectional_score" class="toggle-checkbox" type="checkbox"/>
            <div class="toggle-switch"></div>
            <span class="toggle-label">{{configureToolData.is_sectional_score ? 'Show' : "Don’t Show"}}</span>
          </label>
        </div> 
      </div>
      
      <div class="divider-1"></div>

      <div class="form-group large-15">
        <input v-model="configureToolData.access_code" type="text" placeholder="Enter Access Code" />
        <label>Enter Access Code</label>
      </div>

      <em class="fs-12 black-6">(Access Code links the HireMe assessment to the Jombay Assessment)</em>
     
      <div class="divider-2"></div>
      <div class="large-30">
        <a class="more_actions_btn uppercase fs-12 bold" v-bind:class="[moreActions ? 'open' : 'close']" @click="moreActions = !moreActions">
          More Actions
        </a>
        <em class="fs-12 black-6">(Tool weightage)</em>

        <div class="more_actions_container" v-bind:class="[moreActions ? 'show' : 'hide']">

          <div class="form-group large-15 column">
            <input v-model="configureToolData.tool_weightage" type="text" placeholder="Tool Weightage">
            <label>Tool Weightage</label>
          </div>

        </div>
        
      </div>

    </div>

    <div class="divider-3"></div>
  </div>
</template>

<script>
  export default {
    props: ['configureToolData', 'index'],
    data () {
      return {
        moreActions: false
      }
    }
  }
</script>

<style lang="sass" scoped>
  $color-warning: #ff8308 
  @mixin flex
    display: -webkit-box
    display: -moz-box
    display: -ms-flexbox
    display: -webkit-flex
    display: flex
  .section_title
    color: $color-warning
    padding: 8px
    background: #fff4e9
  .more_actions_btn
    padding-right: 15px
    background: url('~assets/images/ic-dropright-warning.svg') no-repeat right center
    margin-right: 16px
    &.open
      background: url('~assets/images/ic-dropdown-warning.svg') no-repeat right center 
  .more_actions_container
    overflow: hidden
    padding-top: 15px
    &.open
      display: block
</style>