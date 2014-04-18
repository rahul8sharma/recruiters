$( document ).ready(function() {
  var tooltipParentHeight= $('.info-tooltip-control').innerHeight();
  var tooltipHeight= $('.info-tooltip').outerHeight();
  var tooltipTopValue= (tooltipHeight/2) - (tooltipParentHeight/2);
  
  $('.info-tooltip').css({
    top: - tooltipTopValue
  });
 
  $('.control-group input[type="text"]').focus(function() {
    $(this).parent().find(".info-tooltip").fadeIn('slow');
  });
  $('.control-group input[type="text"]').blur(function() {
    $(this).parent().find(".info-tooltip").fadeOut();
  });

});
