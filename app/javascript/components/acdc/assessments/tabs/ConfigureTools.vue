<template>
  <div>
    <div class="action_bar">
      <div class="fs-16 black-9 bold">Follow these steps to configure every tool</div>

      <div class="spacer"></div>

      <div class="info_tooltip">
        <div class="tooltip_text">
          <div class="text_container">
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos necessitatibus, facilis dolorum, impedit fugit voluptatibus nemo unde ut a dolore vero quo sint perspiciatis. Exercitationem saepe cum a vitae! Eligendi.
          </div>
        </div>
      </div>
     
      <button class="button btn-warning uppercase fs-14">
        Save &amp; Next
      </button>
    </div>

    <div class="edit_section">
      <component
        v-for="(currentTool, index) in currentTools"
        v-bind:is="currentTool"
        v-bind:key="index"
        v-bind:configureToolData="tabData.raw_data[index]"
      >
      </component>
      <div class="divider-4"></div>
    </div>

  </div>
</template>

<script>
  import bhive_with_cocubes from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithCoCubes.vue';
  import bhive_with_hire_me from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithHireMe.vue';
  import bhive_with_jombay_aptitude from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithJombayAptitude.vue';
  import mini_hive_with_jombay_abstract_thinking from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithJombayAbstractThinking.vue';
  import mini_hive_with_jombay_critical_thinking from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithJombayCriticalThinking.vue';
  import mini_hive_with_pearson_ravens from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithPearsonRavens.vue';
  import mini_hive_with_wg from 'components/acdc/assessments/tabs/configure_tools/Mini-HIVEwithWG.vue';
  import psychometry from 'components/acdc/assessments/tabs/configure_tools/Psychometry.vue';
 
  export default {
    props: ['tabData'],
    components: {
      bhive_with_cocubes, bhive_with_hire_me, bhive_with_jombay_aptitude,
      mini_hive_with_jombay_abstract_thinking, mini_hive_with_jombay_critical_thinking,
      mini_hive_with_pearson_ravens, mini_hive_with_wg, psychometry
    },
    computed: {
      currentTools: function () {
        return this.tabData.tools
      }
    }
  }
</script>