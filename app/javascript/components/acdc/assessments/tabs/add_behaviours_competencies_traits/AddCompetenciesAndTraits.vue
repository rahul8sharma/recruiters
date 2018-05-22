<template>
  <div>
    <div v-for="(localCompetency, competencyIndex) in tabData.competencies">
      <div class="section_title uppercase fs-12 bold">
        {{ competencyIndex + 1 }}.  {{localCompetency.name}}
      </div>
      <div class="divider-2"></div>
      <div class="large-1 columns pr-20"></div>
      <div class="fs-12 large-8 columns color-warning pr-20">Type Trait name</div>
      <div class="fs-12 large-7 columns color-warning pr-20">Range from</div>
      <div class="fs-12 large-7 columns color-warning pr-20">Range to</div>
      <div class="fs-12 large-5 columns color-warning pr-20">Weightage</div>
      <div class="clr"></div>

      <ul>
        <li v-for="(trait, traitIndex) in localCompetency.selectedFactors" v-if="items[competencyIndex] != null" >
          <div class="fs-16 large-1 columns black-9 line-height-4">{{ traitIndex + 1 }}.</div>
          <div class="select-box large-8 columns pr-20">
            <div class="form-group">
               <select2 :options="items[competencyIndex].factorNames[traitIndex]" v-model="trait.name" :competencyData="{tabData: tabData, competencyIndex: competencyIndex, traitIndex: traitIndex, factors: factors, items: items, options: options}" :initializeData="initializeData" :id="'trait_id_' + (competencyIndex + '' + traitIndex)">
              </select2>
              <label>Trait name</label>
            </div>
            
          </div>
          <div class="select-box large-7 columns pr-20">
            <div class="form-group">
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
          
          <div class="form-group large-3 columns pr-20">
            <input v-model="trait.weight" type="text" placeholder="Weightage" />
            <label>Weightage</label>
          </div>

           <button v-if="((tabData.competencies[competencyIndex].selectedFactors.length -1) != 0)" @click="removeCompetency(traitIndex, competencyIndex)" class="button btn-default btn-link uppercase fs-30 black-10 large-2 columns">&times;</button>

          <div class="clr"></div>
          
        </li>
      </ul>
      <div class="divider-2"></div>
      
      <button @click="addTrait(competencyIndex)" class="button btn-warning btn-link  uppercase fs-16 bold">+ Add More Traits</button>
      
      <div class="divider-2"></div>
      
    </div>
    <div class="large-30">
      <a class="more_actions_btn uppercase fs-12 bold" v-bind:class="[moreActions ? 'open' : 'close']" @click="moreActions = !moreActions">
        More Actions
      </a>
      <em class="fs-12 black-6">(Competency Range)</em>

      <div class="more_actions_container" v-bind:class="[moreActions ? 'show' : 'hide']">
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
  import select2 from './select2.vue'

  export default {
    props: ["competencies", 'tabData'],
    data () {
      return {
        items: [{
          competencySuggestion: [],
          factorNames: []
        }],
        options: [
          {value: 1, text: 'Low'},
          {value: 2, text: 'Below Average'},
          {value: 3, text: 'Average (Low)'},
          {value: 4, text: 'Average (High)'},
          {value: 5, text: 'Above Average'},
          {value: 6, text: 'High'},
        ],
        initializeData: false,
        factorNames: [],
        factors: [],
        isremoveTraitEvent: -1,
        removeTraitValue: '',
        traitIndex: '',
        moreActions: false
      }
    },
    components: {
      ModelSelect, select2
    },
    methods: {
      addTrait(index) {
       this.tabData.competencies[index].selectedFactors.push({
          factor_id: '',
          name: 'Select Trait',
          from_norm_bucket: {value: '', text: ''},
          to_norm_bucket: {value: '', text: ''},
          weight: 1.0
        })
       this.items[index].competencySuggestion.push("Select Trait")
       
       if(this.factorNames.indexOf('Select Trait') > -1) {
       this.items[index].factorNames[this.tabData.competencies[index].selectedFactors.length - 1] = this.factorNames.slice()
       } else {
        this.items[index].factorNames[this.tabData.competencies[index].selectedFactors.length - 1] = this.factorNames.slice()
        this.items[index].factorNames[this.tabData.competencies[index].selectedFactors.length - 1].unshift("Select Trait")
       }

       let traitIndex = this.tabData.competencies[index].selectedFactors.length - 1
       let traits = this.tabData.competencies[index].selectedFactors.map(function(elem){ return elem.name;}).filter((v, i, a) => a.indexOf(v) === i)

        for (var i = 0; i < traits.length; i++) {
          if(traits[i].length != 0 && traits[i] != 'Select Trait') {
            var j = this.items[index].factorNames[traitIndex].indexOf(traits[i]);
            if (j > -1) {
               this.items[index].factorNames[traitIndex].splice(j, 1);
            }
          }
        }
      },
      removeCompetency(traitIndex, competencyIndex) {
        this.removeTraitValue = this.tabData.competencies[competencyIndex].selectedFactors[traitIndex].name

        this.traitIndex = traitIndex
        this.tabData.competencies[competencyIndex].selectedFactors.splice(traitIndex, 1)
        this.tabData.competencies[competencyIndex].factor_ids.splice(traitIndex, 1)
        this.items[competencyIndex].competencySuggestion.splice(traitIndex, 1)
        this.items[competencyIndex].factorNames.splice(traitIndex, 1)
        this.isremoveTraitEvent = competencyIndex
      }
    },
    updated: function() {
      if(this.isremoveTraitEvent != -1) {
        let traitLength = this.tabData.competencies[this.isremoveTraitEvent].selectedFactors.length

        for (let j=0; j<traitLength; j++){
          if(this.removeTraitValue  != 'Select Trait') {
            this.items[this.isremoveTraitEvent].factorNames[j].push(this.removeTraitValue)

            let currentTritId = 'trait_id_' + this.isremoveTraitEvent + '' + j
            let currentTraitSelect = document.getElementById(currentTritId)
            let option = ''
            option = document.createElement("option")
            option.text = this.removeTraitValue
            currentTraitSelect.add(option);
          }
        }

        for (let j=0; j<traitLength; j++){
          var string_copy = (' ' + this.items[this.isremoveTraitEvent].competencySuggestion[j]).slice(1);
          this.tabData.competencies[this.isremoveTraitEvent].selectedFactors[j].name = string_copy
        }
      }
      this.isremoveTraitEvent = -1
      
    },
    created: function() {
      this.get.traits({
        company_id: this.$store.state.AcdcStore.companyId,
        functional_areas_id: this.$store.state.AcdcStore.assessmentRawData.description.functional_area_id.value,
        industry_id: this.$store.state.AcdcStore.assessmentRawData.description.industry_id.value,
        job_experience_id: this.$store.state.AcdcStore.assessmentRawData.description.job_experience_id.value
       })
      .then(response => {
        return response.json()
      })
      .then(data => {
        this.factors = data.factors
        this.factorNames = data.factor_names
        for(var competencyIndex = 0; competencyIndex < this.tabData.competencies.length; competencyIndex ++) {
          if (competencyIndex != 0) {
            this.items.push({competencySuggestion: [], factorNames: []})
          }
          for(var factor in this.tabData.competencies[competencyIndex].selectedFactors) {
            if(this.tabData.competencies[competencyIndex].selectedFactors[parseInt(factor)].name != ""){
              this.items[competencyIndex].competencySuggestion.push(this.tabData.competencies[competencyIndex].selectedFactors[parseInt(factor)].name)
            } else {
              this.items[competencyIndex].competencySuggestion.push('Select Trait')
              this.tabData.competencies[competencyIndex].selectedFactors[parseInt(factor)].name = 'Select Trait'
              this.factorNames.unshift("Select Trait")
            }
            this.initializeData = true
            this.items[competencyIndex].factorNames[parseInt(factor)] = this.factorNames.slice()
          }
          let selectedTrait = this.items[competencyIndex].competencySuggestion.filter(function(v) { return v != 'Select Trait' })
          for(var factor in this.tabData.competencies[competencyIndex].selectedFactors) {
            let traitName = this.tabData.competencies[competencyIndex].selectedFactors[parseInt(factor)].name
            this.items[competencyIndex].factorNames[parseInt(factor)] = this.items[competencyIndex].factorNames[parseInt(factor)].filter(function (item) {
                return selectedTrait.indexOf(item) === -1
            });
            if (traitName != 'Select Trait') {
              this.items[competencyIndex].factorNames[parseInt(factor)].push(traitName)
            }
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
    padding-top: 15px
    &.open
      display: block
</style>
