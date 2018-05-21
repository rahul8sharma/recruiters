<template>
  <div>
    <div class="section_heading flex-box">
      <!-- <span>Behaviour / Competency / Traits</span> -->
      <span>{{isAssessmentClassCompetency ? 'Traits' : 'Competency / Traits'}}</span>
      <div class="spacer"></div>
      <a v-if="!isSendForReview" class="button btn-warning btn-link" @click="changeCurrentTab">
        Edit
      </a>
    </div>
    <div class="content_body fs-14">
      <div class="divider-1"></div>
      <div class="p-8 pb-12 clearfix uppercase black-5 bold">
        <div class="large-10 columns">Name</div>
        <div class="large-4 columns">Weightage</div>
        <div class="large-8 columns">Range from</div>
        <div class="large-8 columns">Range to</div>
      </div>

      <div v-if="isAssessmentClassCompetency">
        <ul class="p-8 black-5">
          <li class="pt-12 clearfix" v-for="(trait, index) in traits">
            <div class="large-10 columns">{{trait.name}}</div>
            <div class="large-4 columns">{{trait.weight}}</div>
            <div class="large-8 columns">{{trait.from_norm_bucket.text}}</div>
            <div class="large-8 columns">{{trait.to_norm_bucket.text}}</div>
          </li>
        </ul>
      </div>
      <div v-else="isAssessmentClassCompetency" v-for="(competency, index) in competencies">
        <div class="sub_heading clearfix">
          <div class="large-10 columns">{{competency.name}}</div>
          <div class="large-4 columns">{{competency.weight}}</div>
          <div class="large-8 columns">NA</div>
          <div class="large-8 columns">na</div>
        </div>
        <ul class="p-8 black-5">
          <li class="pt-12 clearfix" v-for="(trait, index) in competency.selectedFactors">
            <div class="large-10 columns">{{trait.name}}</div>
            <div class="large-4 columns">{{trait.weight}}</div>
            <div class="large-8 columns">{{trait.from_norm_bucket.text}}</div>
            <div class="large-8 columns">{{trait.to_norm_bucket.text}}</div>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<style lang="sass" scoped>
  @import '~assets/css/jit_review'
</style>
<script>
import assessmentHelper from 'helpers/assessment.js'

  export default {
    props: ['assessmentData', 'isSendForReview'],
    methods: {
      changeCurrentTab() {
        this.$store.dispatch('setChangeCurrentTab', {
          currentTab: {text: 'Add Behaviours/ Competencies/ Traits', index: 3}
        })
      }
    },
    computed: {
      isAssessmentClassCompetency () {
        return assessmentHelper.isAssessmentClassCompetency(this.assessmentData)
      },
      traits () {
        return this.assessmentData.add_behaviours_competencies_traits.job_assessment_factor_norms_attributes
      },
      competencies () {
        return this.assessmentData.add_behaviours_competencies_traits.competencies
      }
    }
  }
</script>