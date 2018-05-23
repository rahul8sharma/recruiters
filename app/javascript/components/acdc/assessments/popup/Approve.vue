<template>
  <div class="modal scrollable" v-bind:class="[isApproveModalOpen ? 'modalOpen' : 'hide']">
    <div class="modal-container large-20 p-0">
      <div class="heading fs-14 uppercase">
        <span class="bold">Approve this Assessment</span>
        <div class="spacer"></div>
        <div @click="setApproveModalState" class="close">&times;</div>
      </div>
      <div class="modal-body">
        <p>Clicking on <span class="bold">‘Approve’</span> will enable the sending of the assessment.</p>
        <p>Once the assessment is approved only following parts of the assessment can be changed</p>
        <ol>
        <li>Name</li>
        <li>Competency and trait ranges</li>
        <li>Competency and trait weightages</li>
        <li>Email Templates</li>
        <li>Report configurations</li>
      </ol>
        <p>Please make sure all the other parts correct.</p>
      </div>
      <div class="actions">
        <div class="spacer"></div>
        <button @click="setApproveModalState" class="button btn-link uppercase fs-14 black-7">CANCEL</button>
        <button @click="approve" class="button btn-warning uppercase fs-14">APPROVE</button>
      </div>
    </div>
  </div>
</template>

<script>
  import assessmentUrlHelper from 'helpers/assessmentUrl.js'

  export default {
    props: [ 'isApproveModalOpen', 'setApproveModalState' ],
    methods: {
      approve:function(){
        this.$store.dispatch('updateAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          acdc_assessment: {
            reviewer_id: this.$store.state.AcdcStore.userId,
            status: 'approve'
          }
        }).then(() => {
          window.location = assessmentUrlHelper.getAssessmentUrl(this.$store.state.AcdcStore.companyId)
        })
      }
    }
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
  .pannel-list
    @include flex
    align-items: top
    .list_item
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