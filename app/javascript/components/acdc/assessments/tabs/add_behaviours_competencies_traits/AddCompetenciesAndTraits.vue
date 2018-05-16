<template>
  <div>
    <div v-for="(localCompetency, competencyIndex) in tabData.competencies">
      <div class="section_title uppercase fs-12 bold">
        {{ competencyIndex + 1 }}.  {{localCompetency.name}}
      </div>
      <div class="divider-2"></div>
      <div class="fs-12 large-8 columns color-warning pr-20">Type Trait name</div>
      <div class="fs-12 large-7 columns color-warning pr-20">Range from</div>
      <div class="fs-12 large-7 columns color-warning pr-20">Range to</div>
      <div class="fs-12 large-5 columns color-warning pr-20">Weightage</div>
      <div class="clr"></div>

      <ul>
        <li v-for="(trait, traitIndex) in localCompetency.selectedFactors" >
          <div class="fs-16 large-1 columns black-9 line-height-4">{{ traitIndex + 1 }}.</div>

          <div class="form-group large-8 columns pr-20">
            <v-autocomplete 
              :items="items[competencyIndex].competencySuggestion[traitIndex].suggestion" 
              :min-len='0'
              v-model="trait.name" 
              :get-label="getLabel"
              :component-item='template' 
              @item-selected="itemSelected" 
              placeholder="Type Trait name"
              @update-items="update"
              @focus="setCurrentIndex(traitIndex, competencyIndex)"
              autofocus>
            </v-autocomplete>
            <label>Trait name</label>
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
          
          <div class="form-group large-5 columns pr-20">
            <input v-model="trait.weight" type="text" placeholder="Weightage" />
            <label>Weightage</label>
          </div>

           <button v-if="((tabData.competencies[competencyIndex].selectedFactors.length -1) != 0)" @click="removeCompetency(traitIndex, competencyIndex)" class="button btn-default btn-link uppercase fs-30 black-10 large-3 columns">&times;</button>

          <div class="clr"></div>
          
        </li>
      </ul>
      <div class="divider-2"></div>
      
      <button @click="addTrait(competencyIndex)" class="button btn-warning btn-link  uppercase fs-16 bold">+ Add More Traits</button>
      
      <div class="divider-2"></div>
      
    </div>
    <div class="large-30">
      <a href="#" class="more_actions_btn uppercase fs-12 bold open">
        More Actions
      </a>
      <em class="fs-12 black-6">(Competency Range)</em>

      <div class="more_actions_container open">
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
    props: ["competencies", 'tabData'],
    data () {
      return {
        items: [{
          competencySuggestion: [{
            suggestion: [],
          }]
        }],
        template: ItemTemplate,
        currentTraitIndex:'',
        currentCompetencyIndex:'',
        currentCompetenciesIndex: '',
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
        factor: []
      }
    },
    components: {
      'v-autocomplete': Autocomplete,
      ModelSelect
    },
    methods: {
      addTrait(index) {
       this.tabData.competencies[index].selectedFactors.push({
          factor_id: '',
          name: '',
          from_norm_bucket: {value: '', text: ''},
          to_norm_bucket: {value: '', text: ''},
          weight: 1.0
        })
       this.items[index].competencySuggestion.push({suggestion: []})
      }, 
      itemSelected (factorName) {
        if(!this.initializeData) {
          const competency = this.tabData.competencies[this.currentCompetencyIndex]
          const index = indexWhere(this.factors, item => item.name === factorName)
          const factor = this.factors[index]

          competency.selectedFactors[this.currentTraitIndex].factor_id = factor.id
          competency.selectedFactors[this.currentTraitIndex].name = factor.name
          competency.selectedFactors[this.currentTraitIndex].to_norm_bucket = this.options[(factor.to_norm_bucket_id - 1)]
          competency.selectedFactors[this.currentTraitIndex].from_norm_bucket = this.options[(factor.from_norm_bucket_id - 1)]

          competency.factor_ids[this.currentTraitIndex] = factor.id
        }  
      },
      getLabel (item) {
        if (item) {
          return item
        }
        return ''
      },
      update (text) {
        this.initializeData = false

        this.items[this.currentCompetencyIndex].competencySuggestion[this.currentTraitIndex].suggestion = this.factorNames.filter((item) => {
          return (new RegExp(text.toLowerCase())).test(item.toLowerCase())
        })
      },
      setCurrentIndex(traitIndex, competencyIndex) {
        this.currentTraitIndex = traitIndex
        this.currentCompetencyIndex = competencyIndex
      },
      removeCompetency(traitIndex, competencyIndex) {
        if((this.tabData.competencies[competencyIndex].selectedFactors.length -1) != 0) {
          this.tabData.competencies[competencyIndex].selectedFactors.splice(traitIndex, 1)
          this.tabData.competencies[competencyIndex].factor_ids.splice(traitIndex, 1)  
        }
      }
    },
    created: function() {
      this.initializeData = true
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
      for(var competencyIndex = 0; competencyIndex < this.tabData.competencies.length; competencyIndex ++) {
        this.items.push({competencySuggestion: []})
        for(var factor in this.tabData.competencies[competencyIndex].selectedFactors) {
          this.items[competencyIndex].competencySuggestion.push({suggestion: []})
        }  
      }
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
