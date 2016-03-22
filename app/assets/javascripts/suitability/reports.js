//= require jquery-ui/jquery-ui.js
//= require moment.js
//= require jquery-ui/jquery.comiseo.daterangepicker.min.js
$(function() { 
  $(".daterangepicker").daterangepicker({
    numberOfMonths: 2,
    presetRanges: []
  });

  $('#export_form').on('submit', function(event){
  	$('#exports').removeClass('hide');
  	// return false;
  });

  $('#popup_close').on('click', function(){
  	$('#exports').addClass('hide');
  });

});
