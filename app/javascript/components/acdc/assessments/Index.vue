<template>
  <div id="rahul">
    <Header></Header>
    {{text}}
    <Footer></Footer>
  </div>
</template>

<script>
    import Header from 'components/layout/Header.vue';
    import Footer from 'components/layout/Footer.vue';
  export default {
    components: { Header, Footer },
    data () {
          return {
          text: 'Hello World!'
        }
    }
  }
</script>