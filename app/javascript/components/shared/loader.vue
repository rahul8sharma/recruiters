<template>
  <div class="loaderContainer" id="loader">
    <i class="fs-40">loading..........</i>
  </div>        
</template>

<style lang="sass" scoped>
  .loaderContainer
    position: fixed
    top: 0
    left: 0
    width: 100vw
    height: 100vh
    background: #000000
    background: rgba(0, 0, 0, 0.45)
    z-index: 999999
    justify-content: center
    align-items: center
    display: none
    &.loaderOpen
      display: -webkit-box
      display: -moz-box
      display: -ms-flexbox
      display: -webkit-flex
      display: flex
</style>