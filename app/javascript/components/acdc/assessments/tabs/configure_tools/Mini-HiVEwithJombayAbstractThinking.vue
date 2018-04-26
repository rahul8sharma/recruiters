<template>
  <div class="edit_section">
    <div class="section_title uppercase fs-12 bold">
      2. Mini-HiVE with Jombay Abstract Thinking
    </div>

    <div class="p-15">      
      <div class="divider-1"></div>
      <a href="#" class="more_actions_btn uppercase fs-12 bold open">
        More Actions
      </a>
      <em class="fs-12 black-6">(Tool weightage)</em>

      <div class="more_actions_container open">
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
    props: ['configureToolData']
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