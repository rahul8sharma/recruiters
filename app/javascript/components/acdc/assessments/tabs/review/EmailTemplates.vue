<template>
  <div>
    <div class="section_heading flex-box">
      <span>Email Templates</span>
      <div class="spacer"></div>
      <a v-if="!isSendForReview" class="button btn-warning btn-link" @click="changeCurrentTab">
        Edit
      </a>
    </div>
    <div class="content_body black-5">
      <div class="email_template" v-if="Object.keys(invitation).length !== 0">
        <div class="divider-1"></div>
        <div class="sub_heading">
          A. Invitation
        </div>
         <div class="p-8 fs-16">
           <p class="clearfix">
             <strong class="large-3">From: </strong>
             <span class="large-3"><span v-html="invitation.from"></span></span>
           </p>
           <p class="clearfix">
             <strong class="large-3">Subject: </strong>
             <span class="large-3"><span v-html="invitation.subject"></span></span>
           </p>
           <hr/>
           <div class="pb-12 pt-12">
              <p v-html="invitation.body"></p>
           </div>

         </div>
        
      </div>

      <div class="email_template" v-if="Object.keys(reminder).length !== 0">
        <div class="divider-1"></div>
        <div class="sub_heading">
          B. Reminder
        </div>
         <div class="p-8 fs-16">
           <p class="clearfix">
             <strong class="large-3">From: </strong>
             <span class="large-3"><span v-html="reminder.from"></span></span>
           </p>
           <p class="clearfix">
             <strong class="large-3">Subject: </strong>
             <span class="large-3"><span v-html="reminder.subject"></span></span>
           </p>
           <hr/>
           <div class="pb-12 pt-12">
              <p v-html="reminder.body"></p>
           </div>

         </div>
        
      </div>
      <div class="email_template" v-if="Object.keys(assessmentCompletion).length !== 0">
        <div class="divider-1"></div>
        <div class="sub_heading">
          C. Assessment Completion
        </div>
         <div class="p-8 fs-16">
           <p class="clearfix">
             <strong class="large-3">From: </strong>
             <span class="large-3"><span v-html="assessmentCompletion.from"></span></span>
           </p>
           <p class="clearfix">
             <strong class="large-3">Subject: </strong>
             <span class="large-3"><span v-html="assessmentCompletion.subject"></span></span>
           </p>
           <hr/>
           <div class="pb-12 pt-12">
              <p v-html="assessmentCompletion.body"></p>
           </div>

         </div>
        
      </div>
    </div>
  </div>
</template>

<style lang="sass" scoped>
  @import '~assets/css/jit_review'
</style>
<script>
  export default {
    props: ['assessmentData', 'isSendForReview'],
    data() {
      return {
        assessmentCompletion: {},
        invitation: {},
        reminder: {}
      }
    },
    methods: {
      changeCurrentTab() {
        this.$store.dispatch('setChangeCurrentTab', {
          currentTab: {text: 'Select Template', index: 5}
        })
      }
    },
    created: function() {
      let assessmentCompletionId = this.assessmentData.select_template.assessment_completion_notification_template_id
      let invitationId = this.assessmentData.select_template.invitation_template_id
      let reminderId = this.assessmentData.select_template.reminder_template_id
      this.get.get_templates_by_ids({ company_id: this.$store.state.AcdcStore.companyId,
        invitation_template_id: invitationId,
        reminder_template_id: reminderId,
        completion_notification_template_id: assessmentCompletionId
        })
        .then(response => {
          return response.json()
        })
        .then(data => {
          this.assessmentCompletion = data.completion_notification_templates
          this.invitation = data.invitation_templates
          this.reminder = data.reminder_templates
          if(assessmentCompletionId == null || assessmentCompletionId.length == 0) {
            this.assessmentCompletion = this.assessmentData.select_template.create_completion_notification_template
          }
          if(invitationId == null || invitationId.length == 0) {
            this.invitation = this.assessmentData.select_template.create_invitation_template
          }
          if(reminderId == null || reminderId.length == 0) {
            this.reminder = this.assessmentData.select_template.create_reminder_template
          }
        })
    }
  }
</script>