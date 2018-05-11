<template>
  <div>
    <div class="clearfix">
      <div class="form-group large-3 columns">
        <input type="text" v-model="objectiveQuestion.weightage" placeholder="Weightage"/>
        <label>Weightage</label>
      </div>
      <div class="large-4 columns"></div>

      <div class="large-23 columns">
        <div class="divider-1"></div>

        <label class="custom-checkbox">
          <input  v-model="objectiveQuestion.is_question_uploaded" type="checkbox"/>
          <div class="label-text fs-12">I already have the questions uploaded in the account</div>
        </label>
      </div>
    </div>

    <div class="divider-1"></div>

    <div class="clearfix" v-if="!objectiveQuestion.is_question_uploaded">
      <div class="form-group large-15 columns">
        <input v-model="drive_url" type="text" placeholder="Upload Questions from Google Sheet URL"/>
        <label>Upload Questions from Google Sheet URL</label>
      </div>
      <div class="large-15 columns">
        <button :disabled="isSaveUploadButton" @click="uploadQuestions" href="" class="button btn-warning btn-link uppercase bold line-height-2">Update</button>
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
    
    <div v-for="(section, section_index) in objectiveQuestion.sections">
      <div class="section_title uppercase fs-12 bold">
        {{section_index + 1}} . {{section.section_name}}
      </div>

      <ul class="questions_list" v-for="(question, question_index) in section.data">
        <li class="question fs-16 black-6">
          <div class="question_index">{{question_index + 1}}.</div>
          <div class="question_text">
            {{question.question_body}}
          </div>

          <div class="question_options clearfix">
            <div class="question_option large-15" v-for="(option, option_index) in question.options">
              <label class="pannel_container">
                <div class="input_field" :class="{ checked: option.score == '1' }"></div>
                <div class="pannel">
                  <div class="title">Option {{option_index + 1}}</div>
                  {{option.body}}
                </div>
              </label>
            </div>
          </div>
        </li>
      </ul>
    </div>
  </div>

</template>

<script>
  export default {
    props: ['objectiveQuestion'],
    data () {
      return {
        drive_url: '',
      }
    },
    methods: {
      uploadQuestions() {
        this.$store.dispatch('getGoogleDriveFileByUrl', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          url: this.drive_url
        }).then(() => {
        })
      }
    },
    watch: {
      '$store.state.AcdcStore.googleDriveObjectiveQuestion' (newCount, oldCount) {
        this.objectiveQuestion.sections = this.$store.getters.googleDriveObjectiveQuestion
      }
    },
    computed: {
      isSaveUploadButton: function () {
        return isGoogleDriveUrlValid(this.drive_url)
      }
    }
  }

  function isGoogleDriveUrlValid(url) {
    var googleDriveRegex = /^https?:\/\/([^\/]+)\/([^?]*\/)?([^\/?]+)/;
    return !googleDriveRegex.exec(url);
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
    margin-left: -15px
    .question_option
      padding: 15px
      .pannel_container
        position: relative
        height: 100%
        display: block
        cursor: default
        .input_field
          opacity: 0
          position: absolute
          top: 0
          left: 0
          &:checked, &.checked
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
</style>