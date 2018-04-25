<template>
  <div class="divider-3">
    <component
      v-for="(currentTool, index) in currentTools"
      v-bind:is="currentTool"
      v-bind:configureToolData="tabData.raw_data[index]"
    >
    </component>
  </div>
</template>

<script>
  import BHiVEwithCoCubes from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithCoCubes.vue';
  import BHiVEwithHireMe from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithHireMe.vue';
  import BHiVEwithJombayAptitude from 'components/acdc/assessments/tabs/configure_tools/B-HiVEwithJombayAptitude.vue';
  import MiniHiVEwithJombayAbstractThinking from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithJombayAbstractThinking.vue';
  import MiniHiVEwithJombayCriticalThinking from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithJombayCriticalThinking.vue';
  import MiniHiVEwithPearsonRavens from 'components/acdc/assessments/tabs/configure_tools/Mini-HiVEwithPearsonRavens.vue';
  import Psychometry from 'components/acdc/assessments/tabs/configure_tools/Psychometry.vue';
 
  export default {
    props: ['tabData'],
    components: {
      BHiVEwithCoCubes, BHiVEwithHireMe, BHiVEwithJombayAptitude,
      MiniHiVEwithJombayAbstractThinking, MiniHiVEwithJombayCriticalThinking,
      MiniHiVEwithPearsonRavens, Psychometry
    },
    data () {
      return {
        currentTools: ['Psychometry']
      }
    },
    methods: {}
  }
</script>