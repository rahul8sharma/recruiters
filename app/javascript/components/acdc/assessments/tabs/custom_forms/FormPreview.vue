<template>
  <div class="form_preview">
    <div class="clearfix">
      <div class="fs-14 black-9 line-height-3 bold large-7 columns">
        First Name 
        <span class="color-warning">*</span>
      </div>
      <div class="form-group large-12 columns">
        <input type="text" placeholder="please enter your first name" />
        <label>please enter your first name</label>
      </div>
    </div>

    <div class="clearfix">
      <div class="fs-14 black-9 line-height-3 bold large-7 columns">
        Last Name
        <span class="color-warning">*</span>
      </div>
      <div class="form-group large-12 columns">
        <input type="text" placeholder="please enter your last name" />
        <label>please enter your last name</label>
      </div>
    </div>

    <div class="clearfix">
      <div class="divider-1"></div>
      <div class="fs-14 black-9 bold large-7 columns">
        Select Your Gender
        <span class="color-warning">*</span>
      </div>
      <div class="large-12 columns">
        <div class="large-10 columns">
          <label class="custom-radio">
            <input type="radio" name="gender"/>
            <div class="label-text">Male</div>
          </label>
        </div>
        <div class="large-10 columns">
          <label class="custom-radio">
            <input type="radio" name="gender"/>
            <div class="label-text">Female</div>
          </label>
        </div>
        <div class="large-10 columns">
          <label class="custom-radio">
            <input type="radio" name="gender"/>
            <div class="label-text">Other</div>
          </label>
        </div>
        <div class="clr"></div>
        <div class="divider-1"></div>
      </div>
    </div>
    
    <div class="clearfix">
      <div class="divider-1"></div>
      <div class="fs-14 black-9 line-height-2 bold large-7 columns">
        About yourself
        <span class="color-warning">*</span>
      </div>
      <div class="large-23 columns">
        <textarea data-gramm_editor="false" placeholder="Type here something abpout your interest"></textarea>
      </div>
      <div class="clr"></div>
      <div class="divider-1"></div>
    </div>
    <div class="clearfix">
      <div class="fs-14 black-9 line-height-4 bold large-7 columns">
        Work Experience
        <span class="color-warning">*</span>
      </div>
      <div class="select-box large-12 columns">
        <div class="form-group">
          <model-select :options="options"
            v-model="item"
            placeholder="select an year for your work experience">
          </model-select>
          <label>select an year for your work experience</label>
        </div>
      </div>
    </div>

    <div class="clearfix">
      <div class="divider-1"></div>
      <div class="fs-14 black-9 bold large-7 columns">
        Personel Interest
        <span class="color-warning">*</span>
      </div>
      <div class="large-12 columns">
        <div class="large-10 columns">
          <label class="custom-checkbox">
            <input type="checkbox"/>
            <div class="label-text">Lorem</div>
          </label>
        </div>
        <div class="large-10 columns">
          <label class="custom-checkbox">
            <input type="checkbox"/>
            <div class="label-text">Ipsum</div>
          </label>
        </div>
        <div class="large-10 columns">
          <label class="custom-checkbox">
            <input type="checkbox"/>
            <div class="label-text">Dollor</div>
          </label>
        </div>
        <div class="clr"></div>
        <div class="divider-1"></div>
      </div>
    </div>


  </div>
</template>

<style lang="sass" scoped>
  .form_preview
    border-radius: 2px
    background-color: #f6f6f6
    padding: 30px 16px
  
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