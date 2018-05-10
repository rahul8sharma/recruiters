<template>
  <div class="edit_section">
    <em class="fs-12 black-6 large-12 show">(Type Competencies name to add them in this Assessment, You can arrange the order of the competencies in next step)</em>
    <div class="divider-1"></div>
    <div class="large-1 columns"></div>
    <div class="fs-12 large-13 columns color-warning">
      Type Competency name
    </div>
    <div class="fs-12 large-3 columns color-warning">
      Weightage
    </div>
    <div class="clr"></div>

    <ul>
      <li v-for="(competency, competencyIndex) in tabData.competencies">
        <div class="fs-16 large-1 columns black-9 line-height-4">{{ competencyIndex + 1 }}.</div>

        <div class="form-group large-8 columns">
           <input type="text" v-model="competency.name" placeholder="Competency name" />
           <label>Competency name</label>
        </div>

        <em class="large-6 columns fs-12 black-6 line-height-3">
          0/20 characters
        </em>
        <div class="form-group large-3 columns">
          <input type="text" placeholder="Weightage" v-model="competency.weight" />
          <label>Weightage</label>
        </div>

        <div class="large-2 columns"></div>

        <a href="" :disabled="competencyIndex == (tabData.competencies.length - 1)" @click.prevent="moveDown(competencyIndex)" class="shuffle_action fs-12 uppercase black-6 text-center line-height-3 bold large-3 columns">Move Down</a>
        <a href="" :disabled="competencyIndex == 0" @click.prevent="moveUp(competencyIndex)" class="shuffle_action fs-12 uppercase black-6 text-center line-height-3 bold large-3 columns">Move up</a>
        <div class="clr"></div>
        
      </li>
    </ul>
    <div class="divider-2"></div>
    
    <button @click="addCompetency()" class="button btn-warning btn-link  uppercase fs-16 bold">+ Add More Competency</button>
    
    <div class="divider-2"></div>
    
    <a href="#" class="more_actions_btn uppercase fs-12 bold open">
      More Actions
    </a>
    <em class="fs-12 black-6">(Competency Ranges, Competency Scores, Consistency Report)</em>

    <div class="more_actions_container open">
      <div class="divider-1"></div>
      <div class="clearfix">
        <div class="large-10 columns">
          <label class="custom-checkbox">
            <input v-model="tabData.showCompetencyScoreOnReport" type="checkbox"/>
            <div class="label-text fs-12">Show competency score on report</div>
          </label>
        </div>
        <div class="large-10 columns">
          <label class="custom-checkbox">
            <input v-model="tabData.showConsistencyScoreOnReport" type="checkbox"/>
            <div class="label-text fs-12">Show consistency score on report</div>
          </label>
        </div>
      </div>

    </div>

  </div>
</template>

<script>
  export default {
    props: ['tabData'],
    methods: {
      addCompetency() {
        this.tabData.competencies.push({
          name: "",
          description: "-",
          active: true,
          modules: ["suitability"],
          factor_ids: [],
          company_ids: [this.$store.state.AcdcStore.companyId],
          weight: 1,
          order: this.tabData.competencies.length,
          selectedFactors: [{
            id: '',
            name: '',
            from_norm_bucket: {value: '', text: ''},
            to_norm_bucket: {value: '', text: ''},
            weight: 1.0
          }]
        })
      },      
      moveDown(index) {
        let temp = this.tabData.competencies[index].order = (this.tabData.competencies[index].order + 1 )
        this.tabData.competencies[temp].order = (this.tabData.competencies[temp].order - 1)

        this.tabData.competencies.sort(function(a, b){
          return a.order - b.order });
      },
      moveUp(index) {
        let temp = this.tabData.competencies[index].order = (this.tabData.competencies[index].order - 1 )
        this.tabData.competencies[temp].order = (this.tabData.competencies[temp].order + 1)

        this.tabData.competencies.sort(function(a, b){
          return a.order - b.order });
      }
    }
  }

</script>
<style lang="sass" scoped>
  .shuffle_action
    &:hover
      opacity: 0.6
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