$(function() { 
  $('#export_form').on('submit', function(event){
  	$('#exports').removeClass('hide');
  	$('.popup_modal').center();
  	//  remove this return false when hooking it up with back-end
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