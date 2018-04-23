<template>
  <div class="loaderContainer">
    <div class="loader_icon">
      Loading.................
    </div>


  </div>        
</template>

<style lang="sass" scoped>
  .loader_icon
    width: 30%
    overflow: hidden
    font-size: 80px
    animation: arrow-spin 2s 0s cubic-bezier(0.165, 0.840, 0.440, 1.000) infinite
    color: #fff

    @keyframes arrow-spin
      0%
        width: 0px
      50%
        width: 15%
      100%
        width: 30%
        /*transform: rotate(360deg)*/

      
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