<template>
  <div class="divider-3">
    <component
      v-for="(currentTool, index) in currentTools"
      v-bind:is="currentTool"
      v-bind:key="index"
      v-bind:configureToolData="tabData.raw_data[index]"
    >
    </component>
  </div>
</template>

<script>
  import bhive_with_cocubes from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithCoCubes.vue';
  import bhive_with_hire_me from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithHireMe.vue';
  import bhive_with_jombay_aptitude from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithJombayAptitude.vue';
  import mini_hive_with_jombay_abstract_thinking from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithJombayAbstractThinking.vue';
  import mini_hive_with_jombay_critical_thinking from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithJombayCriticalThinking.vue';
  import mini_hive_with_pearson_ravens from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithPearsonRavens.vue';
  import mini_hive_with_wg from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithPearsonRavens.vue';
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