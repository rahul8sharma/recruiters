// Get assessment edit URL.
function getCompanyAcdcEditUrl(companyId, acdcId) {
  return "/companies/" + companyId + "/acdc/" + acdcId + "/edit"
}

// Get usage of company
function getCompanyUsageUrl(companyId) {
  return "/companies/" + companyId + "/statistics"
}

// Get 360 usage of company
function getCompany360UsageUrl(companyId) {
  return "/companies/" + companyId + "/statistics_360"
}

// Get 360 usage of company
function getCompanyVacUsageUrl(companyId) {
  return "/companies/" + companyId + "/statistics_vac"
}

// Get company settings
function getCompanySettingUrl(companyId) {
  return "/companies/" + companyId
}

// Get training requirements of company
function getCompanyTrainingRequirementsUrl(companyId) {
  return "/companies/" + companyId + "/training-requirements"
}

// Get walk ins of company
function getCompanyWalkInsUrl(companyId) {
  return "/companies/" + companyId + "/walk-ins"
}

// Get 360 degree home of company
function getCompany360HomeUrl(companyId) {
  return "/companies/" + companyId + "/360/home"
}

// Get oac home of company
function getCompanyOacHomeUrl(companyId) {
  return "/companies/" + companyId + "/oac/home"
}

// Get acdc of company
function getCompanyAcdcUrl(companyId) {
  return "/companies/" + companyId + "/acdc"
}

// Get assessments of company
function getCompanyAssessmentUrl(companyId) {
  return "/companies/" + companyId + "/tests"
}

// Get report of company
function getCompanyReportUrl(companyId) {
  return "/companies/" + companyId + "/reports"
}

// Get users search
function getUsersSearchUrl(companyId) {
  return "/companies/" + companyId + "/users_search"
}

// Get company
function getCompanyUrl() {
  return "/companies"
}

// Logout
function getLogoutUrl() {
  return "logout"
}
export default {
  getCompanyAcdcEditUrl, getCompanyUsageUrl, getCompany360UsageUrl,
  getCompanyVacUsageUrl, getCompanySettingUrl, getCompanyTrainingRequirementsUrl,
  getCompanyWalkInsUrl, getCompany360HomeUrl, getCompanyOacHomeUrl, getCompanyAcdcUrl,
  getCompanyAssessmentUrl, getCompanyReportUrl, getUsersSearchUrl, getCompanyUrl,
  getLogoutUrl
}