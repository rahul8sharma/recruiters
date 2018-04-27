<template>
  <div class="modal scrollable" v-bind:class="{modalOpen:isModalOpen}">
    <div class="modal-container large-20">
      <div class="heading fs-14 uppercase">
        <span>Create Assessment</span>
        <div class="spacer"></div>
        <div @click="setModalState" class="close">&times;</div>
      </div>
      <div class="modal-body">
        <div class="create_assessment">
          <form>
            <div class="form-group large-15 column">
              <input type="text" placeholder="Name of Assessment" v-model="assessment.name" :maxlength="nameMaxLength">
              <label>Name of Assessment*</label>
            </div>
            <div class="large-15 column fs-14 black-6">
              <div class="divider-1"></div>
              {{nameMaxLength - assessment.name.length}}/{{nameMaxLength}} characters
            </div>
            <div class="clr"></div>
            <em class="fs-12 black-6">(*The Name of the Assessment appears on the Report and Dashboard)</em>

            <div class="divider-1"></div>
            <div class="section_title uppercase fs-12 bold">
              Select Assessment Type
            </div>
            <div class="assessment-type">
              <div class="divider-1"></div>
              <div class="uppercase fs-14 bold black-9">
                Plain Psychometry 
              </div>
              <ul class="pannel-list">
                <li class="list_item large-7">
                  <label class="pannel_container">
                    <input v-model="assessment.product" value="psychometry" type="radio" name="assessmentType" class="input_field">
                    <div class="pannel">
                      <div class="title">Just Psychometry</div>
                      Plain Old vanilla Psychometry
                    </div>
                  </label>
                </li>
              </ul>
            </div>

            <div class="assessment-type">
              <div class="divider-1"></div>
              <div class="uppercase fs-14 bold black-9">
                BHiVE
              </div>
              <ul class="pannel-list">
                <li class="list_item large-7">
                  <label class="pannel_container">
                    <input v-model="assessment.product" value="bhive_with_cocubes" type="radio" name="assessmentType" class="input_field">
                    <div class="pannel">
                      <div class="title">BHive with Cocubes</div>
                      Psychometry integrated with Cocubes
                    </div>
                  </label>
                </li>
                <li class="list_item large-7">
                  <label class="pannel_container">
                    <input v-model="assessment.product" value="bhive_with_hire_me" type="radio" name="assessmentType" class="input_field">
                    <div class="pannel">
                      <div class="title">BHive with HireMe</div>
                      Psychometry integrated with HireMe
                    </div>
                  </label>
                </li>
                <li class="list_item large-8">
                  <label class="pannel_container">
                    <input v-model="assessment.product" value="bhive_with_jombay_aptitude" type="radio" name="assessmentType" class="input_field">
                    <div class="pannel">
                      <div class="title">BHive with Jombay Aptitude</div>
                      Psychometry integrated Jombay Seamless Experience
                    </div>
                  </label>
                </li>
              </ul>
            </div>

            <div class="assessment-type">
              <div class="divider-1"></div>
              <div class="uppercase fs-14 bold black-9">
                Mini HiVE
              </div>
              <ul class="pannel-list">
                <li class="list_item large-8">
                  <label class="pannel_container">
                    <input v-model="assessment.product" value="mini_hive" type="radio" name="assessmentType" class="input_field">
                    <div class="pannel">
                      <div class="title">MiniHiVE</div>
                      Psychometric Assessment with any other tool
                    </div>
                  </label>
                </li>
              </ul>
              <div v-if="assessment.product == 'mini_hive'">
                <div class="divider-1"></div>
                <em class="fs-12 black-6">(Select multiple tools from below to add them with Psychometric Assessment)</em>
                <div class="divider-1"></div>
                <div class="clearfix" v-for="product in products" v-if="product.attributes.tag == 'mini_hive'">
                  <div class="columns pr-15 pb-25" v-for="tool in product.attributes.tools">
                    <label class="custom-checkbox">
                      <input type="checkbox" :value="tool.name" v-model="assessment.tools" />
                      <div class="label-text fs-12">{{(tool.name.split('_').join(' ')).charAt(0).toUpperCase() + tool.name.split('_').join(' ').substr(1)}}</div>
                    </label>
                  </div>
                </div>
              </div>
              <!--END: Need to fix HTML-->
            </div>

            <div class="assessment-type">
              <div class="divider-1"></div>
              <div class="uppercase fs-14 bold black-9">
                VAC
              </div>
              <ul class="pannel-list">
                <li class="list_item large-7">
                  <label class="pannel_container">
                    <input v-model="assessment.product" value="Virtual Assessment Center" type="radio" name="assessmentType" class="input_field">
                    <div class="pannel">
                      <div class="title">Virtual Assessment Center</div>
                      VAC
                    </div>
                  </label>
                </li>
              </ul>
            </div>
          </form>
        </div>
      </div>
      <div class="actions">
        <div class="spacer"></div>
        <button @click="setModalState" class="button btn-link uppercase fs-14 black-7">Discard</button>
        <button @click="createAssessment" :disabled="isCreateSubmitButtonEnable" class="button btn-warning uppercase fs-14">Create Assessment</button>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    props: [
      'isModalOpen',
      'setModalState',
      'isCreateSubmitButtonEnable',
      'assessment',
      'createAssessment',
      'products'
    ],
    data () {
      return {
        nameMaxLength: 20
      }
    },
    watch: {
      'assessment.product': function(val, oldVal){
        this.assessment.tools = []
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
