$(document).ready(function() {
  // Validation for signup form
  $('#signupForm').validate(
    $.extend(
      {
        rules: {
          "user[email]": {
            required: true,
            email: true
          },
          "user[name]": {
            required: true
          },
          "user[password]": {
            required: true,
            minlength: 8
          },
          "user[password_confirmation]": {
            required: true,
            equalTo: "#user_password"
          }
        }
      }, bootstrap_error_settings
    )
  );
});