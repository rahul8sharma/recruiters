$(document).ready(function() {
    // Form validation
    $('#formResetPassword').validate(
        $.extend(
            {
                rules: {
                    "user[password]": {
                        required: true,
                        minlength: 8
                    }, 
                    "user[password_confirmation]": {
                        required: true,
                        equalTo: "#user_password"
                    }
                },
                messages: {
                    "user[password_confirmation]": {
                        equalTo: "The 2 passwords do not match"
                    }
                }

            }, bootstrap_error_settings
        )
    );
});