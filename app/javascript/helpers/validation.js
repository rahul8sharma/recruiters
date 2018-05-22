// Check maxlength of field and validate.
function checkLengthInterval(fieldValue, maxLength) {
  return fieldValue.trim().length > maxLength || fieldValue.trim().length == 0
}

// Check, Is field empty
function isEmpty(fieldValue) {
  return fieldValue.trim().length == 0
}

export default { checkLengthInterval, isEmpty }