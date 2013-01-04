$(document).ready(function() {
  // Validation for login form
  $('#newCompanyProfileForm').validate(
    $.extend(
      {
        rules: {
          "type": {
              required: true
          },
          "company[name]": {
              required: true
          },
          "company[location][geography_id]": {
              required: true
          }
        }
      }, bootstrap_error_settings
    )
  );
});