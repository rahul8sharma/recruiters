// Get assessment edit URL.
function getAssessmentEditUrl(companyId, acdcId) {
  return "/companies/" + companyId + "/acdc/" + acdcId + "/edit"
}

export default { getAssessmentEditUrl }