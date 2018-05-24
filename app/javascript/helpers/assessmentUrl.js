// Get assessment edit URL.
function getAssessmentEditUrl(companyId, acdcId) {
  return "/companies/" + companyId + "/acdc/" + acdcId + "/edit"
}

// Get assessment URL.
function getAssessmentUrl(companyId) {
  return "/companies/" + companyId + "/acdc"
}

export default { getAssessmentEditUrl, getAssessmentUrl }