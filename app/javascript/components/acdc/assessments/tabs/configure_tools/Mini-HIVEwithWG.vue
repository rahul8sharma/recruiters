<template>
  <div>
    <div class="section_title uppercase fs-12 bold">
      {{index}}. Mini-HiVE with WG
    </div>

    <div class="p-15">
      <div class="large-12 pt-12">
        <em class="fs-12 black-6">(The Watson-Glaser™ Critical Thinking Appraisal is the leader in assessing critical thinking ability and predicting performance in fast-paced positions requiring high-level thinking and analysis. It measures a combination of critical thinking attitudes, knowledge, and skills.)</em>
      </div>
      <div class="divider-1"></div>
      <div class="form-group large-15">
        <input v-model="configureToolData.url" type="text" placeholder="Enter Redirection URL">
        <label>Enter Redirection URL</label>
      </div>

      <div class="large-15">
        <em class="fs-12 black-6">(System will take the assessment taker to this URL once he/she is done with Psychometry assessment)</em>
      </div>
      <div class="divider-2"></div>

      <div class="clearfix">
        
        <trumbowyg 
          v-model="configureToolData.thank_you_message"
          :config="configs"
          class="form-control"
          placeholder="Thank you page"
        >
        </trumbowyg>

        <!-- <div class="large-14 columns fs-14 black-6 p-16">
          0/400 characters
        </div> -->
      </div>
     
      <div class="divider-2"></div>
      <div class="large-30">
        <a class="more_actions_btn uppercase fs-12 bold" v-bind:class="[moreActions ? 'open' : 'close']" @click="moreActions = !moreActions">
          More Actions
        </a>
        <em class="fs-12 black-6">(Tool weightage)</em>

        <div class="more_actions_container" v-bind:class="[moreActions ? 'show' : 'hide']">

          <div class="form-group large-15">
            <input v-model="configureToolData.tool_weightage" type="text" placeholder="Tool Weightage">
            <label>Tool Weightage</label>
          </div>

        </div>
        
      </div>

    </div>

    <div class="divider-3"></div>
  </div>
</template>

<script>
import trumbowyg from 'vue-trumbowyg/dist/vue-trumbowyg.js';
import 'trumbowyg/dist/ui/trumbowyg.css';

  export default {
    props: ['configureToolData', 'index'],
    components: { trumbowyg },
    data () {
      return {
        moreActions: false,
        configs: {
          autogrow: true,
          autogrowOnEnter: true,
          removeformatPasted: true,
          btnsAdd: ['foreColor', 'backColor'],
          btns: [
            ['formatting'],
            ['strong', 'em', 'del'],
            ['superscript', 'subscript'],
            ['link'],
            ['insertImage'],
            ['justifyLeft', 'justifyCenter', 'justifyRight', 'justifyFull'],
            ['unorderedList', 'orderedList'],
            ['horizontalRule'],
            ['removeformat'],
            ['fullscreen']
          ]
        }
      }
    }
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
  .more_actions_btn
    padding-right: 15px
    background: url('~assets/images/ic-dropright-warning.svg') no-repeat right center
    margin-right: 16px
    &.open
      background: url('~assets/images/ic-dropdown-warning.svg') no-repeat right center 
  .more_actions_container
    overflow: hidden
    padding-top: 15px
    &.open
      display: block
  .text-editor
    height: 120px
    background-color: #ffffff
    border: solid 1px #eaeaea
</style>