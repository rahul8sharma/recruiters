<template>
  <div class="edit_section">
    <div class="section_title uppercase fs-12 bold">
      2. Mini-HiVE with Pearson Ravens
    </div>

    <div class="p-15">
      <div class="divider-1"></div>
      <div class="form-group large-15">
        <input type="text" placeholder="Enter Redirection URL">
        <label>Enter Redirection URL</label>
      </div>

      <div class="large-15">
        <em class="fs-12 black-6">(System will take the assessment taker to this URL once he/she is done with Psychometry assessment)</em>
      </div>
      <div class="divider-2"></div>

      <div class="clearfix">

        <div class="large-16 columns">
          <div class="text-editor">
            WYSIWYG Editor for Thank you page
          </div>
        </div>

        <div class="large-14 columns fs-14 black-6 p-16">
          0/400 characters
        </div>
      </div>
     
      <div class="divider-2"></div>

      <a href="#" class="more_actions_btn uppercase fs-12 bold open">
        More Actions
      </a>
      <em class="fs-12 black-6">(Tool weightage)</em>

      <div class="more_actions_container open">

        <div class="form-group large-15">
          <input type="text" placeholder="Tool Weightage">
          <label>Tool Weightage</label>
        </div>

      </div>

    </div>

    <div class="divider-3"></div>
  </div>
</template>

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
  .text-editor
    height: 120px
    background-color: #ffffff
    border: solid 1px #eaeaea
</style>