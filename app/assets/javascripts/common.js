//= require jquery
//= require jquery_ujs

$(document).ready(function() {
    $(".alert .close").on('click', function() {
        $(".alert").hide(500);
    })
});