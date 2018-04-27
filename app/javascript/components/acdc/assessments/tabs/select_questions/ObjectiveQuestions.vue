<template>
  <div class="edit_section">
    <div class="clearfix">
      <div class="form-group large-3 columns">
        <input type="text" placeholder="Weightage"/>
        <label>Weightage</label>
      </div>
      <div class="large-4 columns"></div>

      <div class="large-23 columns">
        <div class="divider-1"></div>

        <label class="custom-checkbox">
          <input type="checkbox"/>
          <div class="label-text fs-12">I already have the questions uploaded in the account</div>
        </label>
      </div>
    </div>

    <div class="divider-1"></div>

    <div class="clearfix">
      <div class="form-group large-15 columns">
        <input type="text" placeholder="Upload Questions from Google Sheet URL"/>
        <label>Upload Questions from Google Sheet URL</label>
      </div>
      <div class="large-15 columns">
        <a href="" class="button btn-warning btn-link uppercase bold line-height-2">Update</a>
      </div> 
    </div>

    <div class="divider-1"></div>
    
    <div class="large-15">
      <div class="clearfix">
        <div class="fs-14 pr-16 line-height-2 black-10 uppercase left">Or</div>
        <a href="" class="button btn-warning fs-14 uppercase inverse left">Download Format</a>
      </div>

      <div class="divider-1"></div>

      <hr/>
      
    </div>

    <div class="divider-1"></div>  

    <div class="fs-16 black-9 bold">Preview:</div>
    
    <div class="divider-1"></div>  
    
    <div class="section_title uppercase fs-12 bold">
      1.  Lorem Ipsum Competency
    </div>

    <ul class="questions_list">
      <li class="question fs-16 black-6">
        <div class="question_index">1.</div>
        <div class="question_text">
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ante urna, tempor vitae tempus nec, pellentesque in eros. Vestibulum volutpat diam cursus scelerisque egestas?
        </div>

        <div class="question_options clearfix">
          <div class="question_option large-15">
            <label class="pannel_container">
              <input value="psychometry" type="radio" name="assessmentType" class="input_field">
              <div class="pannel">
                <div class="title">Option 1</div>
                Psychometry integrated with Pearson
              </div>
            </label>
          </div>

          <div class="question_option large-15">
            <label class="pannel_container">
              <input value="psychometry" type="radio" name="assessmentType" class="input_field">
              <div class="pannel">
                <div class="title">Option 1</div>
                Psychometry integrated with Pearson
              </div>
            </label>
            
          </div>
        </div>
        
      </li>
    </ul>

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
  .questions_list
    padding-left: 25px
    .question
      position: relative
      padding: 25px 0
      .question_index
        position: absolute
        top: 25px
        left: -25px
  .question_options
    @include flex
    align-items: top
    flex-wrap: wrap
    .question_option
      padding: 15px
      &:first-child
        padding-left: 0
      .pannel_container
        position: relative
        height: 100%
        display: block
        cursor: pointer
        .input_field
          opacity: 0
          position: absolute
          top: 0
          left: 0
          &:checked
            & + .pannel
              background-color: $color-warning
              color: #fff
              box-shadow: 0 8px 10px 0 rgba(255, 131, 8, 0.2)
              border-color: $color-warning
              .title
                color: #fff

        .pannel
          border-radius: 2px
          background-color: #f6f6f6
          min-height: 100px
          border: 1px solid #d3d3d3
          color: rgba(0, 0, 0, 0.6)
          padding: 12px
          font-size: 12px
          height: 100%
           
          .title
            color: rgba(0, 0, 0, 0.87)
            margin-bottom: 10px
            font-weight: 600

      &:hover
        .pannel
          background-color: $color-warning
          color: #fff
          box-shadow: 0 8px 10px 0 rgba(255, 131, 8, 0.2)
          border-color: $color-warning
          opacity: 0.7
          .title
            color: #fff
</style>
<script>
  export default {
  }
</script>