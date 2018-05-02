<template>
  <div class="review_section">
    <div class="section_heading flex-box">
      <span>Custom Forms</span>
      <div class="spacer"></div>
      <a href="" class="button btn-warning btn-link">
        Edit
      </a>
    </div>
    <div class="content_body fs-14">
      <div class="p-8">
        <p class="clearfix">
          <strong class="large-7 columns line-height-4">First Name: </strong>
          <span class="form-group disabled large-15 columns">
            <input type="text" placeholder="please enter your first name"/>
          </span>
        </p>
        <p class="clearfix">
          <strong class="large-7 columns line-height-4">Last Name: </strong>
          <span class="form-group disabled large-15 columns">
            <input type="text" placeholder="please enter your last name"/>
          </span>
        </p>
        <div class="divider-1"></div>
        <p class="clearfix">
          <strong class="large-7 columns">Select Your Gender: </strong>
          <span class="large-15 columns">
            <label class="custom-radio large-10 columns show">
              <input type="radio"/>
              <span class="label-text">Male</span>
            </label>
            <label class="custom-radio large-10 columns show">
              <input type="radio"/>
              <span class="label-text">Female</span>
            </label>
            <label class="custom-radio large-10 columns show">
              <input type="radio"/>
              <span class="label-text">Other</span>
            </label>
            <span class="clr"></span>
          </span>
        </p>
        <div class="divider-1"></div>
        <p class="clearfix">
          <strong class="large-7 columns">Nationality: </strong>
          <span class="large-15 columns">
            <label class="custom-checkbox large-10 columns show">
              <input type="checkbox"/>
              <span class="label-text">Indian</span>
            </label>
            <label class="custom-checkbox large-10 columns show">
              <input type="checkbox"/>
              <span class="label-text">NRI</span>
            </label>
            <span class="clr"></span>
          </span>
        </p>
        <div class="divider-1"></div>
        <p class="clearfix">
          <strong class="large-7 columns">General Info: </strong>
          <span class="large-15 columns">
            <textarea class="bg-black-1" data-gramm_editor="false" placeholder="Type here your general info"></textarea>
          </span>
        </p>

      </div>

    </div>
  </div>
</template>

<style lang="sass" scoped>
  @import '~assets/css/jit_review'
</style>
<script>
  export default {
  }
</script>