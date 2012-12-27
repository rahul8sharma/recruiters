$(function() {
  // Initialise raty, the rating plugin
  $("[data-rating]").raty({
    score: function() {
      return $(this).attr('data-rating');
    },
    path: "/assets/lib/raty/img",
    hints: ['bad', 'poor', 'regular', 'good', 'great'],
    'size':0,
    click: function(score, evt) {
      // Submit rating to server
      $.ajax({
        type: 'PUT',
        url: $(this).attr("data-rate_application"),
        data: {employer_rating: score, token: token},
        dataType: 'json',
        success: function(data){
          console.log(data);
        },
        error: function(data, textStatus, XMLHttpRequest){
          alert("Sorry, an error has occured. Please try again!");
        },
        complete: function(jqXHR, textStatus){
        }
      });
    }
  });
});