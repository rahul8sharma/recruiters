<template>
  <div class="modal scrollable modalOpen">
    <div class="modal-container large-20">
      <div class="heading fs-14 uppercase bold">
        <span>Edit Template</span>
        <div class="spacer"></div>
        <div class="close">&times;</div>
      </div>

      <div class="modal-body p-0 ">
        <div class="create_new_template flex-box">
          <div class="large-20 ">
            <div class="p-30 pb-0">
              <div class="clearfix fs-16  black-9">
                <div class="large-5 columns bold line-height-4">From: </div>
                <div class="form-group large-25 columns bold">
                  <input type="text" placeholder="From"/>
                  <label>From</label>
                </div>
              </div>

              <div class="clearfix fs-16  black-9">
                <div class="large-5 columns bold line-height-4">Subject:  </div>
                <div class="form-group large-25 columns bold">
                  <input type="text" placeholder="Subject"/>
                  <label>Subject</label>
                </div>
              </div>
            </div>

            <hr/>

            <div class="text_editor">
              .large
            </div>

          </div>

          <div class="template_variables large-10 ">
            <div class="p-18">
              <div class="fs-16 black-9">Template Variables:</div>
              <em class="fs-12 black-6">(Click on a template variable to add it to the template body)</em>
              <div class="divider-1"></div>
              <ul>
                <li>
                  <a href="" class="variables">1. Assessment Taker’s Name</a>
                </li>
                 <li>
                  <a href="" class="variables">18. Assessment Link</a>
                </li>
              </ul>
            </div>  
          </div>
          

        </div>

        <div class="actions">
          <div class="large-10">
            <a href="" class="p-10 black-9 bold">&lt; &gt;</a>
            <a href="" class="p-10 black-9">
              <img src="~assets/images/ic-attachment.svg" alt="">
            </a>
          </div>
          <div class="spacer"></div>
          <button class="button btn-warning uppercase fs-14">Save</button>
        </div>
      </div>
    </div>
  </div>
</template>
<style lang="sass" scoped>
  .text_editor
    min-height: 200px
  .create_new_template
    align-items: stretch !important
  .template_variables
    border-left: 2px solid rgba(0, 0, 0, 0.1)
    .variables
      color: rgba(0, 0, 0, 0.54)
      text-decoration: underline
      font-size: 14px

      &:hover
        opacity: 0.6
  
</style>
<script>
  export default {

  }
</script>