$(document).ready(function() {
    // Form validation
    $('#formForgotPassword').validate(
        $.extend(
            {
                rules: {
                    "user[email]": {
                        "required": true,
                        "email": true
                    }
                }
            }, bootstrap_error_settings
        )
    );
});