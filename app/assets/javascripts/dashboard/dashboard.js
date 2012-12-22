$(function() {
  $("[data-section_collapser]").on("click", function(e) {
  	$(this).parents("[data-section]").find("[data-section_content]").slideToggle();
  	e.preventDefault();
  });
});