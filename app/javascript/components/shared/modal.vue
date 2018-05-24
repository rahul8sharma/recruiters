<template>
  <div class="modal scrollable" v-bind:class="[isModalOpen ? 'modalOpen' : 'hide']">
    <div class="modal-container large-20 p-0">
      <div class="heading fs-14 uppercase">
        <span class="bold">{{headerText}}</span>
        <div class="spacer"></div>
        <div @click="setModalState" class="close">&times;</div>
      </div>
      <div class="modal-body">
        <slot></slot>
      </div>
      <div class="actions">
        <div class="spacer"></div>
        <button @click="setModalState" class="button btn-link uppercase fs-14 black-7">{{cancelText}}</button>
        <button :disabled="isButtonDisable" @click="confirmMethod" class="button btn-warning uppercase fs-14">{{confirmText}}</button>
      </div>
    </div>
  </div>
</template>

<script>
  import assessmentUrlHelper from 'helpers/assessmentUrl.js'

  export default {
    props: [ 
      'isModalOpen',
      'setModalState',
      'headerText',
      'cancelText',
      'confirmText',
      'confirmMethod',
      'isButtonDisable'
    ]
  }
</script>

<style lang="sass" scoped>
  $color-warning: #ff8308 
  @mixin flex
    display: -webkit-box
    display: -moz-box
    display: -ms-flexbox
    display: -webkit-flex
    display: flex
  .section_title
    color: $color-warning
    padding: 8px
    background: #fff4e9
  .pannel-list
    @include flex
    align-items: top
    .list_item
      padding: 15px
      &:first-child
        padding-left: 0
      .pannel_container
        position: relative
        height: 100%
        display: block
        cursor: pointer
        .input_field
          opacity: 0
          position: absolute
          top: 0
          left: 0
          &:checked
            & + .pannel
              background-color: $color-warning
              color: #fff
              box-shadow: 0 8px 10px 0 rgba(255, 131, 8, 0.2)
              border-color: $color-warning
              .title
                color: #fff

        .pannel
          border-radius: 2px
          background-color: #f6f6f6
          border: 1px solid #d3d3d3
          color: rgba(0, 0, 0, 0.6)
          padding: 12px
          font-size: 12px
          height: 100%
           
          .title
            color: rgba(0, 0, 0, 0.87)
            margin-bottom: 10px
            font-weight: 600

      &:hover
        .pannel
          background-color: $color-warning
          color: #fff
          box-shadow: 0 8px 10px 0 rgba(255, 131, 8, 0.2)
          border-color: $color-warning
          opacity: 0.7
          .title
            color: #fff
</style>