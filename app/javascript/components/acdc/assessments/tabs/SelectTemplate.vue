<template>
  <div class="edit_section">
    <button @click="changeTemplate('Invitation')">Invitation</button>
    <button @click="changeTemplate('CompletionNotification')">Completion Notification</button>
    <button @click="changeTemplate('Reminder')">Reminder</button>
    <SelectTemplate
      v-bind:currentTemplates="currentTemplates"
      v-bind:tabData="data"
      v-bind:formatTemplates="formatTemplates"
      v-if="show"
    ></SelectTemplate>
    <!-- email_template/New.vue -->
  </div>
</template>

<script>
  import SelectTemplate from 'components/acdc/assessments/tabs/email_template/Select.vue'

  export default {
    props: ['tabData'],
    data () {
      return  {
        templates: '',
        currentTemplate: 'Invitation',
        currentTemplates: {},
        formatTemplates: [],
        data: '',
        show: true
      }
    },
    methods: {
      changeTemplate(currentTemplate) {
        this.show = false
        switch(currentTemplate) {
          case 'Invitation':
            this.assignData(this.templates.invitation_templates, this.tabData.raw_data.invitation_template)
            break;
          case 'CompletionNotification':
            this.assignData(this.templates.completion_notification_templates, this.tabData.raw_data.completion_notification_templates)
            break;
          case 'Reminder':
            this.assignData(this.templates.reminder_templates, this.tabData.raw_data.reminder_templates)
            break;
        }
      },
      assignData(templatesData, setTabData) {
        this.formatTemplates = []
        this.currentTemplates = templatesData
        this.data = setTabData
        this.show = true
        for(var index = 0; index < this.currentTemplates.length; index ++) {
          this.formatTemplates.push({value: index, text: this.currentTemplates[index].name})
        }
      }
    },
    components: { SelectTemplate },
    created: function() {
     this.get.select_templates({ company_id: 2 })
      .then(response => {
        return response.json()
      })
      .then(data => {
        this.templates = data

        // assign default data
        this.assignData(this.templates.invitation_templates, this.tabData.raw_data.invitation_template)
      });

    }
  }

</script>