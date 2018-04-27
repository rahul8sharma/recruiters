<template>
  <div class="edit_section">
    <em class="fs-12 black-6 large-12 show">(Type Competencies name to add them in this Assessment, You can arrange the order of the competencies in next step)</em>
    <div class="divider-1"></div>
    <div class="large-1 columns"></div>
    <div class="fs-12 large-13 columns color-warning">
      Type Competency name
    </div>
    <div class="fs-12 large-3 columns color-warning">
      Weightage
    </div>
    <div class="clr"></div>

    <ul>
      <li>
        <div class="fs-16 large-1 columns black-9 line-height-4">1.</div>

        <div class="form-group large-7 columns">
          <input type="text" placeholder="Competency name" />
          <label>Competency name</label>
        </div>

        <em class="large-6 columns fs-12 black-6 line-height-3">
          11/20 characters
        </em>
        <div class="form-group large-3 columns">
          <input type="text" placeholder="Weightage" />
          <label>Weightage</label>
        </div>

        <div class="large-2 columns"></div>

        <a href="" class="shuffle_action fs-12 uppercase black-6 text-center line-height-3 bold large-3 columns">Move Down</a>
        <a href="" class="shuffle_action fs-12 uppercase black-6 text-center line-height-3 bold large-3 columns">Move up</a>
        <div class="clr"></div>
        
      </li>
    </ul>
    <div class="divider-2"></div>
    
    <button class="button btn-warning btn-link  uppercase fs-16 bold">+ Add More Competency</button>
    
    <div class="divider-2"></div>
    
    <a href="#" class="more_actions_btn uppercase fs-12 bold open">
      More Actions
    </a>
    <em class="fs-12 black-6">(Competency Ranges, Competency Scores, Consistency Report)</em>

    <div class="more_actions_container open">
      <div class="divider-1"></div>
      <div class="clearfix">
        <div class="large-10 columns">
          <label class="custom-checkbox">
            <input type="checkbox"/>
            <div class="label-text fs-12">Show competency score on report</div>
          </label>
        </div>
        <div class="large-10 columns">
          <label class="custom-checkbox">
            <input type="checkbox"/>
            <div class="label-text fs-12">Show consistency score on report</div>
          </label>
        </div>
      </div>

    </div>

  </div>
</template>
<style lang="sass" scoped>
  .shuffle_action
    &:hover
      opacity: 0.6
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
<script>
  export default {
  }
</script>