$(document).ready(function() {
  // Validation for login form
  $('#editCompanyProfileForm').validate(
    $.extend(
      {
        rules: {
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

  $('#editProfileForm').validate(
    $.extend(
      {
        rules: {
          "user[name]": {
              required: true
          },
          "user[phone]": {
              required: true,
              minlength: 10,
              maxlength: 10,
              number: true
          },
          "user[email]": {
              required: true,
              email: true
          }
        }
      }, bootstrap_error_settings
    )
  );
});