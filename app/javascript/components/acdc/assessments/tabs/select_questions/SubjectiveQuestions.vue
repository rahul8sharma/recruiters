<template>
  <div class="edit_section p-0">
    <div class="p-30">
      <div class="text_editor">
        Text Editor here
      </div>
    </div>

    <hr/>


    <div class="questions p-30">
      <div class="fs-15 black-10 bold">Questions</div>
      <ul class="questions_list">
        <li class="questions_item">
          <div class="large-20 left">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ante urna, tempor vitae tempus nec, pellentesque <span class="blank">Blank</span> in eros. Vestibulum volutpat diam cursus scelerisque egestas?
          </div>
          <div class="large-10 left">
            <a href="" class="button btn-warning btn-link uppercase bold line-height-2">remove</a>
          </div> 
          <div class="clr"></div>
        </li>
        <li class="questions_item">
          <div class="large-20 left">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ante urna, tempor vitae tempus nec, pellentesque <span class="blank">Blank</span> in eros. Vestibulum volutpat diam cursus scelerisque egestas?
          </div>
          <div class="large-10 left">
            <a href="" class="button btn-warning btn-link uppercase bold line-height-2">remove</a>
          </div> 
          <div class="clr"></div>
        </li>
      </ul>
    </div>

  </div>
</template>
<style lang="sass" scoped>
  .text_editor
    background-color: #f6f6f6
    height: 150px
  .questions
    max-height: 215px
    overflow: auto
  .questions_list
    padding-left: 20px
    .questions_item
      list-style-type: decimal
      padding: 15px 0
      color: rgba(0, 0, 0, 0.6)
      .blank
        color: rgba(0, 0, 0, 0.9)
        font-weight: 600
</style>
<script>
  export default {
  }
</script>