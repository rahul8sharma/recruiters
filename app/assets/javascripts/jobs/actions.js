$(function() {
  console.log("ACTIONS.JS");
  $("[data-duplicate_job]").on("click", function(e) {
  	console.log("CLICKKKKK");
  	$(this).closest("form").submit();
  	// $.post($(this).attr("href"), $(this).serialize(), null, "script");
  	e.preventDefault();
  });
});	