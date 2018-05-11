<template>
  <div>
    <div class="section_title uppercase fs-12 bold">
      2. B-HiVE with CoCubes
    </div>

    <div class="p-15">
      <div class="divider-2"></div>
      <div class="clearfix">
        <div class="fs-16 black-9 large-5 columns">
          Select the flow of the assessment
          <span class="color-warning">*</span>
        </div>
        <div class="large-3 columns"></div>
        <div class="large-5 columns">
          <label class="custom-radio">
            <input
              v-model="configureToolData.assessment_flow"
              type="radio"
              name="PsychometryType"
              value="Sectional Score"
            />
            <div class="label-text">Sectional Score</div>
          </label>
        </div>
        <div class="large-5 columns">
          <label class="custom-radio">
            <input
              v-model="configureToolData.assessment_flow"
              type="radio"
              name="PsychometryType"
              value="Put Scores in traits"
            />
            <div class="label-text">Put Scores in traits</div>
          </label>
        </div>
      </div>


      <div class="divider-3"></div>

      <a class="more_actions_btn uppercase fs-12 bold" v-bind:class="[moreActions ? 'open' : 'close']" @click="moreActions = !moreActions">
        More Actions
      </a>
      <em class="fs-12 black-6">(Tool weightage)</em>

      <div class="more_actions_container" v-bind:class="{'open':moreActions}">

        <div class="form-group large-15 column">
          <input v-model="configureToolData.tool_weightage" type="text" placeholder="Tool Weightage">
          <label>Tool Weightage</label>
        </div>

      </div>

    </div>

    <div class="divider-3"></div>
  </div>
</template>

<script>
  export default {
    props: ['configureToolData'],
    data () {
      return {
        moreActions: false
      }
    },
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
    display: none
    padding-top: 15px
    &.open
      display: block
</style>