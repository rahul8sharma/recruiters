$(document).ready(function() {
  // Validation for login form
  $('#loginForm').validate(
    $.extend(
      {
        rules: {
          "user[email]": {
              required: true,
              email: true
          },
          "user[password]": {
              required: true
          }
        }
      }, bootstrap_error_settings
    )
  );
});