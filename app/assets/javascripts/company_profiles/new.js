$(document).ready(function() {
  // Validation for login form
  $('#newCompanyProfileForm').validate(
    $.extend(
      {
        rules: {
          "company[type]": {
              required: true
          },
          "company[name]": {
              required: true
          },
          "company[location]": {
              required: true
          }
        }
      }, bootstrap_error_settings
    )
  );
});