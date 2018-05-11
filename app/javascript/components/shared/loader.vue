<template>
  <div class="loaderContainer">
    <img src="~assets/images/loader.gif" alt="">
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
    display: none
    background: rgba(255, 255, 255, 0.8)
    cursor: progress
    img
      max-width: 100%
      max-height: 100%
    &.loaderOpen
      display: -webkit-box
      display: -moz-box
      display: -ms-flexbox
      display: -webkit-flex
      display: flex
</style>