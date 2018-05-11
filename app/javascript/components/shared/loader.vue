<template>
  <div class="loaderContainer">
    <img src="~assets/images/loader.gif" alt="">
  <!--   <div class="loader_icon">
      Loading.................
    </div>
 -->

  </div>        
</template>

<style lang="sass" scoped>
 
  .loaderContainer
    position: absolute
    top: 0
    left: 0
    width: 100%
    height: 100%
    z-index: 999999999
    justify-content: center
    align-items: center
    display: flex
    background: url('~assets/images/loader.gif') no-repeat center center rgba(255, 255, 255, 0.8)
    cursor: progress
    img
      max-width: 100%
    &.loaderOpen
      display: -webkit-box
      display: -moz-box
      display: -ms-flexbox
      display: -webkit-flex
      display: flex
</style>