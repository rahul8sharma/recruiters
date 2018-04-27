<template>
  <div class="edit_section">

    <div class="section_title uppercase fs-12 bold">
      1.  Lorem Ipsum Competency
    </div>
    <div class="divider-2"></div>
    <div class="fs-12 large-8 columns color-warning pr-20">Type Trait name</div>
    <div class="fs-12 large-7 columns color-warning pr-20">Range from</div>
    <div class="fs-12 large-7 columns color-warning pr-20">Range to</div>
    <div class="fs-12 large-5 columns color-warning pr-20">Weightage</div>
    <div class="clr"></div>

    <ul>
      <li>

        <div class="form-group large-8 columns pr-20">
          <input type="text" placeholder="Type Trait name" />
          <label>Trait name</label>
        </div>
        <div class="select-box large-7 columns pr-20">
          <div class="form-group">
            <multi-select
              placeholder="Range from">
            </multi-select>
            <label>Range from</label>
          </div>
        </div>
        <div class="select-box large-7 columns pr-20">
          <div class="form-group">
            <multi-select
              placeholder="Range to">
            </multi-select>
            <label>Range to</label>
          </div>
        </div>

        
        <div class="form-group large-5 columns pr-20">
          <input type="text" placeholder="Weightage" />
          <label>Weightage</label>
        </div>

        <div class="clr"></div>
        
      </li>
    </ul>
    <div class="divider-2"></div>
    
    <button class="button btn-warning btn-link  uppercase fs-16 bold">+ Add More Traits</button>
    
    <div class="divider-2"></div>
    
    <a href="#" class="more_actions_btn uppercase fs-12 bold open">
      More Actions
    </a>
    <em class="fs-12 black-6">(Competency Range)</em>

    <div class="more_actions_container open">
      <div class="divider-1"></div>
      <div class="clearfix">
        <div class="large-10 columns">
          <label class="custom-checkbox">
            <input type="checkbox"/>
            <div class="label-text fs-12">Show Consistency Scores on report</div>
          </label>
        </div>
       
      </div>

    </div>

  </div>
</template>
<style lang="sass" scoped>
  $color-warning: #ff8308
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
<script>
  export default {
  }
</script>