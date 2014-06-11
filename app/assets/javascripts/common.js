//= require jquery
//= require jquery_ujs

$(document).ready(function() {
    $(".alert .close").on('click', function() {
        $(".alert").hide(500);
    });


    //-- Back to top --//
    $('.scroll').click(function(){
      $('html, body').animate({
          scrollTop: $( $.attr(this, 'href') ).offset().top - 37
      }, 500);
      return false;
    });
    // hide #back-top first
    $("#back-top").hide();
    // fade in #back-top
    $(function () {
      $(window).scroll(function () {
        if ($(this).scrollTop() > 100) {
          $('#back-top').fadeIn();
        } else {
          $('#back-top').fadeOut();
        }
      });
      // scroll body to 0px on click
      $('#back-top a').click(function () {
        $('body,html').animate({
          scrollTop: 0
        }, 400);
        return false;
      });
    });
    //-- Back to top --//
});