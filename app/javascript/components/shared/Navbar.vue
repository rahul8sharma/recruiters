<template>
  <div id="header">
    <div class="container">
      <div class="logo left">
        <a href="/" target="_self">
          <img alt="Jombay-logo" src="https://companies.ur-nl.com/assets/jombay-logo-16f7d4c08113f48df7044d3c90f07e6a.png">
        </a>
        <div class="divider-1"></div>
      </div>
      <div class="large-7 company_name left" title="SPI Cinemas">
        SPI Cinemas
      </div>
      <div class="large-19 right">
        <ul class="right" id="sub-nav">
          <li>
            <a class="setting" href="#" title="Account"></a>
            <ul class="fs-14">
              <li>
                <a :href="getCompanyUsageUrl">Usage</a>
              </li>
              <li>
                <a :href="getCompany360UsageUrl">360 Usage</a>
              </li>
              <li>
                <a :href="getCompanyVacUsageUrl">VAC Usage</a>
              </li>
              <li>
                <a :href="getCompanySettingUrl">Settings</a>
              </li>
              <li>
                <a :href="getCompanyTrainingRequirementsUrl">Group TRR</a>
              </li>
              <li>
                <a :href="getCompanyWalkInsUrl">Walk-Ins</a>
              </li>
              <li>
                <a :href="getLogoutUrl">Logout</a>
              </li>
            </ul>
          </li>
        </ul>
        <ul class="right first" id="sub-nav">
          <li>
            <a class="setting other-apps" href="#" title="Account">
              OTHERS
            </a>
            <ul class="fs-14">
              <li>
                <a class="mrf" :href="getCompany360HomeUrl" title="360 Degree">
                  360 DEGREE
                </a>
              </li>
              <li>
                <a class="mrf" :href="getCompanyOacHomeUrl" title="Online Assessment Center">
                  VAC
                </a>
              </li>
            </ul>
          </li>
        </ul>
        <ul class="navbar right clearfix">
          <li>
            <a :href="getCompanyUrl" title="COMPANIES">
              COMPANIES
            </a>
          </li>
          <li>
            <a class="active" :href="getCompanyAcdcUrl" title="ACDC">
              ACDC
            </a>
          </li>
          <li>
            <a :href="getCompanyAssessmentUrl" title="ASSESSMENTS">
              ASSESSMENTS
            </a>
          </li>
          <li>
            <a class="" :href="getCompanyReportUrl" title="REPORTS">
              REPORTS
            </a>
          </li>
          <li>
            <a class="search-menu" :href="getUsersSearchUrl" title="Search"></a>
          </li>
        </ul>
        <div class="clr"></div>
      </div>
      <div class="clr"></div>

    </div>
  </div>
</template>

<script>
  import assessmentUrlHelper from 'helpers/assessmentUrl.js'

  export default {
    computed: {
      getCompanyUsageUrl: function () {
        return assessmentUrlHelper.getCompanyUsageUrl(this.$store.state.AcdcStore.companyId)
      },
      getCompany360UsageUrl: function () {
        return assessmentUrlHelper.getCompany360UsageUrl(this.$store.state.AcdcStore.companyId)
      },
      getCompanyVacUsageUrl: function () {
        return assessmentUrlHelper.getCompanyVacUsageUrl(this.$store.state.AcdcStore.companyId)
      },
      getCompanySettingUrl: function () {
        return assessmentUrlHelper.getCompanySettingUrl(this.$store.state.AcdcStore.companyId)
      },
      getCompanyTrainingRequirementsUrl: function () {
        return assessmentUrlHelper.getCompanyTrainingRequirementsUrl(this.$store.state.AcdcStore.companyId)
      },
      getCompanyWalkInsUrl: function () {
        return assessmentUrlHelper.getCompanyWalkInsUrl(this.$store.state.AcdcStore.companyId)
      },
      getCompany360HomeUrl: function () {
        return assessmentUrlHelper.getCompany360HomeUrl(this.$store.state.AcdcStore.companyId)
      },
      getCompanyOacHomeUrl: function () {
        return assessmentUrlHelper.getCompanyOacHomeUrl(this.$store.state.AcdcStore.companyId)
      },
      getCompanyAcdcUrl: function () {
        return assessmentUrlHelper.getCompanyAcdcUrl(this.$store.state.AcdcStore.companyId)
      },
      getCompanyAssessmentUrl: function () {
        return assessmentUrlHelper.getCompanyAssessmentUrl(this.$store.state.AcdcStore.companyId)
      },
      getCompanyReportUrl: function () {
        return assessmentUrlHelper.getCompanyReportUrl(this.$store.state.AcdcStore.companyId)
      },
      getUsersSearchUrl: function () {
        return assessmentUrlHelper.getUsersSearchUrl(this.$store.state.AcdcStore.companyId)
      },
      getCompanyUrl: function () {
        return assessmentUrlHelper.getCompanyUrl()
      },
      getLogoutUrl: function () {
        return assessmentUrlHelper.getLogoutUrl()
      }
    }
  }
</script>