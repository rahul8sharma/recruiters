$(function() { 
  $('#export_form').on('click', function(event){
  	$('#exports').removeClass('hide');
  	$('.popup_modal').center();
    return false;
  });

  $('#popup_close').on('click', function(){
  	$('#exports').addClass('hide');
  });

});

jQuery.fn.center = function () {
	this.css("margin-top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + $(window).scrollTop()) + "px");
	return this;
}