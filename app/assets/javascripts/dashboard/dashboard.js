$(function() {
  $("[data-section_collapser]").on("click", function(e) {
  	$(this).parents("[data-section]").find("[data-section_content]").slideToggle();
  	e.preventDefault();
  });

  $("[data-post_new_job]").on("click", function(e) {
  	$("form[data-job_post_form]").submit();
  	e.preventDefault();
  })
});