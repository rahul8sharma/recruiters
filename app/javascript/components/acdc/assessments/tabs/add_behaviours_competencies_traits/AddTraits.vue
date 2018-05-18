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
          <select2 :options="items[traitIndex]" v-model="trait.name" :id="'trait_id_' +  traitIndex"
           :traitData="{tabData: tabData.job_assessment_factor_norms_attributes, traitIndex: traitIndex, items: items, factors: factors, options: options, selectedtraits:selectedtraits}"
           :initializeData="initializeData">
            </select2>
          <label>Trait name</label>
        </div>
        <div class="select-box large-7 columns pr-20">
          <div class="form-gro  up">
            <model-select :options="options"
              v-model="trait.from_norm_bucket"
              placeholder="Range from">
            </model-select>
            <label>Range from</label>
          </div>
        </div>
        <div class="select-box large-7 columns pr-20">
          <div class="form-group">
            <model-select :options="options"
            v-model="trait.to_norm_bucket"
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

      <div class="more_actions_container" v-bind:class="{'open':moreActions}">
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
  import { ModelSelect } from 'vue-search-select'
  import select2 from './TraitsOnlySelect2.vue'

  export default {
    props: ['tabData'],
    data () {
      return {
        items: [],
        selectedtraits: [],
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
        moreActions: false,
        initializeData: false,
        isremoveTraitEvent: -1
      }
    },
    components: {
      ModelSelect, select2
    },
    methods: {
      addTrait() {
        this.tabData.job_assessment_factor_norms_attributes.push({
          factor_id: '',
          name: 'Select Trait',
          from_norm_bucket: {value: '', text: ''},
          to_norm_bucket: {value: '', text: ''},
          weight: 1
        })
        this.selectedtraits.push("Select Trait")

        if(this.factorNames.indexOf('Select Trait') > -1) {
          this.items[this.tabData.job_assessment_factor_norms_attributes.length -1] = this.factorNames.slice()
         } else {
          this.items[this.tabData.job_assessment_factor_norms_attributes.length -1] = this.factorNames.slice()
          this.items[this.tabData.job_assessment_factor_norms_attributes.length -1].unshift("Select Trait")
         }
        
       let traitIndex = this.tabData.job_assessment_factor_norms_attributes.length - 1
       let traits = this.tabData.job_assessment_factor_norms_attributes.map(function(elem){ return elem.name;}).filter((v, i, a) => a.indexOf(v) === i)

        for (var i = 0; i < traits.length; i++) {
          if(traits[i].length != 0 && traits[i] != 'Select Trait') {
            var j = this.items[traitIndex].indexOf(traits[i]);
            if (j > -1) {
               this.items[traitIndex].splice(j, 1);
            }
          }
        }  
      }, 
     
      removeTrait(traitIndex) {
        this.removeTraitValue = this.tabData.job_assessment_factor_norms_attributes[traitIndex].name

        this.tabData.job_assessment_factor_norms_attributes.splice(traitIndex, 1)
        this.selectedtraits.splice(traitIndex, 1)
        this.items.splice(traitIndex, 1)
        this.isremoveTraitEvent = traitIndex
      },
    },
    updated: function() {
      if(this.isremoveTraitEvent != -1) {
        let traitLength = this.tabData.job_assessment_factor_norms_attributes.length

        for (let j=0; j<traitLength; j++){
          if(this.removeTraitValue  != 'Select Trait') {
            this.items[j].push(this.removeTraitValue)

            let currentTritId = 'trait_id_' + j
            let currentTraitSelect = document.getElementById(currentTritId)
            let option = ''
            option = document.createElement("option")
            option.text = this.removeTraitValue
            currentTraitSelect.add(option);
          }
        }

        for (let j=0; j<traitLength; j++){
          var string_copy = (' ' + this.selectedtraits[j]).slice(1);
          this.tabData.job_assessment_factor_norms_attributes[j].name = string_copy
        }
      }
      this.isremoveTraitEvent = -1
      
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
        for(var factor in this.tabData.job_assessment_factor_norms_attributes) {
          if(this.tabData.job_assessment_factor_norms_attributes[parseInt(factor)].name != ""){
            this.selectedtraits.push(this.tabData.job_assessment_factor_norms_attributes[parseInt(factor)].name)
          } else {
            this.selectedtraits.push('Select Trait')
            this.tabData.job_assessment_factor_norms_attributes[parseInt(factor)].name = 'Select Trait'
            this.factorNames.unshift("Select Trait")
          }
          this.initializeData = true
          this.items[parseInt(factor)] = this.factorNames.slice()
        }
        let selectedTrait = this.selectedtraits.filter(function(v) { return v != 'Select Trait' })
        for(var factor in this.tabData.job_assessment_factor_norms_attributes) {
          let traitName = this.tabData.job_assessment_factor_norms_attributes[parseInt(factor)].name
          this.items[parseInt(factor)] = this.items[parseInt(factor)].filter(function (item) {
              return selectedTrait.indexOf(item) === -1
          });
          if (traitName != 'Select Trait') {
            this.items[parseInt(factor)].push(traitName)
          }
        }
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
    display: none
    padding-top: 15px
    &.open
      display: block
</style>
