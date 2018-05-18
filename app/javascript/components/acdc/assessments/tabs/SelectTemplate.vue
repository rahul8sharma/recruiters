<template>
  <div>
    <div class="action_bar">
      <div class="fs-16 black-9 link_breadcrumb uppercase">
        <a @click="changeTemplate('Invitation')" v-bind:class="{active:templateName == 'invitation_template_id'}">INVITATION</a>
        <a @click="changeTemplate('Reminder')" v-bind:class="{active:templateName == 'reminder_template_id'}">REMINDER</a>
        <a @click="changeTemplate('CompletionNotification')" v-bind:class="{active:templateName == 'assessment_completion_notification_template_id'}">COMPLETION NOTIFICATION</a>
      </div>

      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos necessitatibus, facilis dolorum, impedit fugit voluptatibus nemo unde ut a dolore vero quo sint perspiciatis. Exercitationem saepe cum a vitae! Eligendi.
          </div>
        </div>
      </div>
     
      <button 
        class="button btn-warning uppercase fs-14" 
        @click="saveAndNext"
        :disabled = "isSaveNextButtonDisabled"
      >
        Save &amp; Next
      </button>
    </div>
    <div class="edit_section">
      <SelectTemplate
        v-bind:currentTemplates="currentTemplates"
        v-bind:templateName="templateName"
        v-bind:tabData="tabData.raw_data"
        v-bind:formatTemplates="formatTemplates"
        v-bind:createTemplateName="createTemplateName"
        v-bind:model="model"
        v-if="show"
      ></SelectTemplate>
      <div class="divider-4"></div>
      <NewTemplate v-if="model.showModel"
        v-bind:currentTemplates="currentTemplates"
        v-bind:templateName="templateName"
        v-bind:createTemplateName="createTemplateName"
        v-bind:tabData="tabData.raw_data"
        v-bind:templateVariables="templates.template_variables"
        v-bind:model="model"
        ></NewTemplate>
    </div>
  </div>
</template>

<script>
  import SelectTemplate from 'components/acdc/assessments/tabs/email_template/Select.vue'
  import NewTemplate from 'components/acdc/assessments/tabs/email_template/New.vue'

  export default {
    props: ['tabData'],
    data () {
      return  {
        templates: '',
        currentTemplate: 'Invitation',
        currentTemplates: {},
        formatTemplates: [],
        templateName: '',
        createTemplateName: '',
        show: true,
        model: {
          showModel: false,
          selectTemplated: {},
          item: {
            value: '',
            text: ''
          }
        },
        isSaveNextButtonDisabled: true
      }
    },
    methods: {
      changeTemplate(currentTemplate) {
        this.show = false
        switch(currentTemplate) {
          case 'Invitation':
            this.assignData(this.templates.invitation_templates, "invitation_template_id", "create_invitation_template")
            break;
          case 'CompletionNotification':
            this.assignData(this.templates.completion_notification_templates, "assessment_completion_notification_template_id", "create_completion_notification_template")
            break;
          case 'Reminder':
            this.assignData(this.templates.reminder_templates, "reminder_template_id", "create_reminder_template")
            break;
        }
      },
      assignData(templatesData, setTabData, createTemplateName) {
        this.formatTemplates = []
        this.currentTemplates = templatesData
        this.templateName = setTabData
        this.createTemplateName = createTemplateName
        this.show = true
        for(var index = 0; index < this.currentTemplates.length; index ++) {
          this.formatTemplates.push({value: index, text: this.currentTemplates[index].name})
        }
      },
      saveAndNext() {
        this.$store.dispatch('updateAcdcAssessment', {
          assessmentId: this.$store.state.AcdcStore.assessmentId,
          companyId: this.$store.state.AcdcStore.companyId,
          acdc_assessment: {select_templates: this.tabData.raw_data}
        })
      }
    },
    components: { SelectTemplate, NewTemplate },
    created: function() {
     this.get.select_templates({ company_id: 2 })
      .then(response => {
        return response.json()
      })
      .then(data => {
        this.templates = data

        // assign default data
        this.assignData(this.templates.invitation_templates, "invitation_template_id", "create_invitation_template")
      });
    },
    watch: {
      tabData: {
         handler(val){
           if(Object.keys(this.tabData.raw_data).length !== 0) {
            this.isSaveNextButtonDisabled = isValidForm(this.tabData.raw_data)
          } else {
            this.isSaveNextButtonDisabled = true
          }
         },
         deep: true
      }
    }
  }

  function isValidForm(raw_data) {
    var isInvitationTemplateIdValid = true, isReminderTemplateIdValid = true
    if (raw_data.invitation_template_id != null ) {
      isInvitationTemplateIdValid = raw_data.invitation_template_id.length == 0
    }
    if (raw_data.reminder_template_id != null ) {
      isReminderTemplateIdValid = raw_data.reminder_template_id.length == 0
    }
    return (
        isInvitationTemplateIdValid
        && Object.keys(raw_data.create_invitation_template).length == 0
      ) || (
        isReminderTemplateIdValid
        && Object.keys(raw_data.create_reminder_template).length == 0
      )
  }
</script>