<template>
  <div>
    <div class="p-20">
      <div class="divider-1"></div>
      <div class="flex-box">
        <div>
          <div class="fs-16 black-9 bold">Invitation Template</div>
          <div class="divider-1"></div>
          <label class="custom-checkbox">
            <input type="checkbox"/>

            <!-- only if this action needed -->
            <div class="label-text fs-12 black-9">Disable assessment completion notification</div>

          </label>
        </div>
        <div class="spacer"></div>
        <div>
          <a href="" class="button btn-warning inverse uppercase fs-14 bold">Create New Template</a>
        </div>
      </div>
      <div class="divider-2"></div>

      <div class="select-box large-15">
        <div class="form-group">
          <model-select
            placeholder="Select Template from Existing">
          </model-select>
          <label>Select Template from Existing</label>
        </div>
      </div>

      <div class="divider-2"></div>

    </div>
    
    <hr/>
    <div class="p-20">
      <div class="form_preview">
        <div class="clearfix">
          <div class="fs-16 black-9 bold left">Form Preview:</div>
          <a href="" class="button btn-warning btn-link uppercase fs-14 bold right">Edit Template</a>
        </div>
      </div>
      <div class="preview_container black-6">
        <div class="p-20">
          <div class="clearfix">
            <strong class="large-4 columns show">From: </strong>
            <div class="large-26 columns">loremipsum@jombay.com</div>
          </div>
          <div class="clearfix">
            <strong class="large-4 columns show">Subject: </strong>
            <div class="large-26 columns">Lorem Ipsum Subject for this Assessment</div>
          </div>
        </div>

        <hr/>

        <div class="p-20">
          <p>Hello &lt;employee name&gt;,</p>
          
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ante urna, tempor vitae tempus nec, pellentesque in eros. Vestibulum volutpat diam cursus scelerisque egestas.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="sass" scoped>
  *
    line-height: normal
  .preview_container
    background: #f6f6f6
</style>

<script>
  export default {
  }
</script>