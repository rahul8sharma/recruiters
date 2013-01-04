$(function() {
  $("[data-star]").each(function() {
  	var score = parseInt($(this).attr("data-star_rating"))/10;
  	$(this).raty({
  	  'path':'/assets/lib/raty/img',
  	  'score':score,
  	  'number':4,
  	  'readOnly':true,
  	  'size':0
    });
  });
});