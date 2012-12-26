$(function() {
  $("[data-duplicate_job]").on("click", function(e) {
  	$(this).closest("form").submit();
  	e.preventDefault();
  });
});	