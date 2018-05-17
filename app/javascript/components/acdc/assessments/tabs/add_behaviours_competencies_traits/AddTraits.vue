<template>
  <div>
    <div class="divider-2"></div>
    <div class="fs-12 large-8 columns color-warning pr-20">Type Trait name</div>
    <div class="fs-12 large-7 columns color-warning pr-20">Range from</div>
    <div class="fs-12 large-7 columns color-warning pr-20">Range to</div>
    <div class="fs-12 large-5 columns color-warning pr-20">Weightage</div>
    <div class="clr"></div>

    <ul>
      <li v-for="(trait, traitIndex) in tabData.job_assessment_factor_norms_attributes" >
        <div class="fs-16 large-1 columns black-9 line-height-4">{{ traitIndex + 1 }}.</div>

        <div class="form-group large-8 columns pr-20">
          <v-autocomplete 
            :items="items" 
            :min-len='0'
            v-model="trait.name" 
            :get-label="getLabel"
            :component-item='template' 
            @item-selected="itemSelected" 
            placeholder="Type Trait name"
            @update-items="update"
            @focus="setCurrentIndex(traitIndex)"
            autofocus>
          </v-autocomplete>
          <label>Trait name</label>
        </div>
        <div class="select-box large-7 columns pr-20">
          <div class="form-group">
            <model-select :options="options"
              v-model="trait.from_norm_bucket_id"
              placeholder="Range from">
            </model-select>
            <label>Range from</label>
          </div>
        </div>
        <div class="select-box large-7 columns pr-20">
          <div class="form-group">
            <model-select :options="options"
            v-model="trait.to_norm_bucket_id"
            placeholder="Range from">
            </model-select>
            <label>Range to</label>
          </div>
        </div>
        
        <div class="form-group large-5 columns pr-20">
          <input v-model="trait.weight" type="text" placeholder="Weightage" />
          <label>Weightage</label>
        </div>

         <button v-if="((tabData.job_assessment_factor_norms_attributes.length -1) != 0)" @click="removeTrait(traitIndex)" class="button btn-default btn-link uppercase fs-30 black-10 large-3 columns">&times;</button>
  
        <div class="clr"></div>
        
      </li>
    </ul>
    <div class="divider-2"></div>
    
    <button @click="addTrait()" class="button btn-warning btn-link  uppercase fs-16 bold">+ Add More Traits</button>
    
    <div class="divider-2"></div>
    <div class="large-30">
      <a class="more_actions_btn uppercase fs-12 bold" v-bind:class="[moreActions ? 'open' : 'close']" @click="moreActions = !moreActions">
        More Actions
      </a>
      <em class="fs-12 black-6">(Competency Range)</em>

      <div class="more_actions_container" v-bind:class="[moreActions ? 'show' : 'hide']"">
        <div class="divider-1"></div>
        <div class="clearfix">
          <div class="large-10 columns">
            <label class="custom-checkbox">
              <input v-model="tabData.showTraitConsistencyScoresonReport" type="checkbox"/>
              <div class="label-text fs-12">Show Consistency Scores on report</div>
            </label>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import Autocomplete from 'v-autocomplete'
  import ItemTemplate from './ItemTemplate.vue'
  import { ModelSelect } from 'vue-search-select'

  export default {
    props: ['tabData'],
    data () {
      return {
        items: [],
        template: ItemTemplate,
        currentTraitIndex:'',
        options: [
          {value: 1, text: 'Low'},
          {value: 2, text: 'Below Average'},
          {value: 3, text: 'Average (Low)'},
          {value: 4, text: 'Average (High)'},
          {value: 5, text: 'Above Average'},
          {value: 6, text: 'High'},
        ],
        factors: [],
        factorNames: [],
        moreActions: false
      }
    },
    components: {
      'v-autocomplete': Autocomplete,
      ModelSelect
    },
    methods: {
      addTrait() {
        this.tabData.job_assessment_factor_norms_attributes.push({
          factor_id: '',
          name: '',
          from_norm_bucket_id: 0,
          to_norm_bucket_id: 0,
          weight: 1
        })
      }, 
      itemSelected (factorName) {
        const index = indexWhere(this.factors, item => item.name === factorName)
        const factor = this.factors[index]
        const jobFactor = this.tabData.job_assessment_factor_norms_attributes

        jobFactor[this.currentTraitIndex].factor_id = factor.id
        jobFactor[this.currentTraitIndex].to_norm_bucket_id = factor.from_norm_bucket_id
        jobFactor[this.currentTraitIndex].from_norm_bucket_id = factor.to_norm_bucket_id
        jobFactor[this.currentTraitIndex].name = factor.name
      },
      getLabel (item) {
        if (item) {
          return item
        }
        return ''
      },
      update (text) {
        this.items = this.factorNames.filter((item) => {
          return (new RegExp(text.toLowerCase())).test(item.toLowerCase())
        })
      },
      setCurrentIndex(traitIndex) {
        this.currentTraitIndex = traitIndex
      },
      removeTrait(traitIndex) {
        if((this.tabData.job_assessment_factor_norms_attributes.length -1) != 0) {
          this.tabData.job_assessment_factor_norms_attributes.splice(traitIndex, 1)
        }
      },
      reset () {
        this.trait.from_norm_bucket_id = ''
      },
      selectOption () {
        // select option from parent component
        this.trait.from_norm_bucket_id = this.options[0].value
      },
      reset2 () {
        this.trait.to_norm_bucket_id = ''
      },
      selectOption2 () {
        // select option from parent component
        this.trait.to_norm_bucket_id = this.options[0].value
      }
    },
    created: function() {
      // TODO need to Update 
      this.get.traits({
        company_id: 2,
        functional_areas_id: 1,
        industry_id: 1,
        job_experience_id: 1
       })
      .then(response => {
        return response.json()
      })
      .then(data => {
        this.factors = data.factors
        this.factorNames = data.factor_names
      });
    }
  }

  function indexWhere(array, conditionFn) {
    const item = array.find(conditionFn)
    return array.indexOf(item)
  }
  
</script>

<style lang="sass" scoped>
  $color-warning: #ff8308
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
</style>
