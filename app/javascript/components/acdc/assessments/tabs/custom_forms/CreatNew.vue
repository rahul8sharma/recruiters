<template>
  <div class="modal scrollable modalOpen">
    <div class="modal-container large-20">
      <div class="heading fs-14 uppercase">
        <span>Create / Edit Custom Form</span>
        <div class="spacer"></div>
        <div class="close">&times;</div>
      </div>

      <div class="modal-body p-0">
        <div class="create_new_form">
          <form>
            <div class="p-30">
              <div class="form-group large-15 column">
                <input type="text" placeholder="Name of the form:" />
                <label>Name of the form:</label>
              </div>

              <div class="large-15 column fs-14 black-6">
                <div class="divider-1"></div>
                11/24 characters
              </div>

              <div class="clr"></div>
              <em class="fs-12 black-6">(*The Name of the form appears on the Report and Dashboard)</em>
            </div>

            <ul class="field_list">
              <li class="field_list_item">
                <div class="index">1.</div>

                <div class="clearfix">
                  <div class="select-box large-7 columns">
                    <div class="form-group">
                      <model-select :options="options" 
                        v-model="item"
                        placeholder="Type">
                      </model-select>
                      <label>Type</label>
                    </div>
                  </div>

                  <div class="large-3 columns"></div>
                  <div class="form-group large-7 columns">
                    <input type="text" placeholder="Identifier" />
                    <label>Identifier</label>
                  </div>

                  <div class="shuffle_actions right">
                    <a class="shuffle_action disabled">Move Down</a>
                    <a class="shuffle_action">Move Down</a>
                    <div class="clr"></div>
                  </div>
                  <div class="clr"></div>
                </div>

                <div class="divider-1"></div>

                <div class="clearfix">
                  <div class="form-group large-7 columns">
                    <input type="text" placeholder="Label" />
                    <label>Label</label>
                  </div>

                  <div class="large-2 columns"></div>

                  <div class="form-group large-12 columns">
                    <input type="text" placeholder="Placeholder" />
                    <label>Placeholder</label>
                  </div>

                  <div class="large-2 columns"></div>

                  <div class="form-group large-7 columns">
                    <input type="text" placeholder="Default Value" />
                    <label>Default Value</label>
                  </div>

                  <div class="clr"></div>
                </div>

                <div class="divider-1"></div>
                
                <div class="clearfix">
                  <div class="form-group large-18">
                    <input type="text" placeholder="Validator Regex" />
                    <label>Validator Regex</label>
                  </div>
                </div>

                <div class="divider-1"></div>
                
                <div class="clearfix flex-box">
                  <div class="toggleSwitch">
                    <label class="toggle">
                      <input class="toggle-checkbox" type="checkbox">
                      <div class="toggle-switch"></div>
                      <span class="toggle-label">Active</span>
                    </label>
                  </div> 
                  <div class="large-2"></div>
                  <label class="custom-checkbox">
                    <input type="checkbox"/>
                    <div class="label-text">Mandatory</div>
                  </label>    
                </div>

                <div class="divider-1"></div>
                <div class="large-20">
                  <textarea class="bg-black-1" data-gramm_editor="false" placeholder="Type here something abpout your interest"></textarea>
                </div>

              </li>
            </ul>
          </form>
        </div>

        <div class="actions">
          <button class="button btn-warning btn-link  uppercase fs-14">+ Add More Competency</button>
          <div class="spacer"></div>
          <button class="button btn-warning uppercase fs-14">Save</button>
        </div>
      </div>
    </div>
  </div>
</template>
<style lang="sass" scoped>
  .field_list
    .field_list_item
      position: relative
      padding: 30px
      padding-left: 55px
      border-top: 1px solid  rgba(0, 0, 0, 0.1)
      .index
        position: absolute
        left: 25px
        top: 55px
        font-weight: 600
        color: rgba(0, 0, 0, 0.9)
      .shuffle_actions
        .shuffle_action
          cursor: pointer
          float: left
          font-weight: 600
          color: rgba(0, 0, 0, 0.54)
          &:first-child
            margin-right: 35px
          &:hover
            opacity: 0.6
          &.disabled
            color: rgba(0, 0, 0, 0.24)
            cursor: not-allowed
            &:hover
              color: rgba(0, 0, 0, 0.24)
              opacity: 1    

</style>
<script>
  import { ModelSelect } from 'vue-search-select'
 
  export default {
    data () {
      return {
        options: [
          { value: '1', text: 'aa' + ' - ' + '1' },
          { value: '2', text: 'ab' + ' - ' + '2' },
          { value: '3', text: 'bc' + ' - ' + '3' },
          { value: '4', text: 'cd' + ' - ' + '4' },
          { value: '5', text: 'de' + ' - ' + '5' }
        ],
        item: {
          value: '',
          text: ''
        },
        searchText: '', // If value is falsy, reset searchText & searchItem
        items: [],
        lastSelectItem: {}
      }
    },
   
    components: {
      ModelSelect
    }
  }
</script>