<template>
  <div>
    <Header></Header>
    <ReportConfigurationLoad></ReportConfigurationLoad>
    <Footer></Footer>
  </div>
</template>

<script>
    import Header from 'components/layout/Header.vue';
    import Footer from 'components/layout/Footer.vue';
    import ReportConfigurationLoad from 'components/acdc/report_configurations/Load.vue';
  export default {
    components: { Header, Footer, ReportConfigurationLoad },
    data () {
          return {
          text: 'Hello World!'
        }
    }
  }
</script>