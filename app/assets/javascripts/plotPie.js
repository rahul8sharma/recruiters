var all_canvas = document.getElementsByTagName('canvas');
var pieData;
var ctx;
for (var i = 0; i < all_canvas.length; i++) {
  var ctx = all_canvas[i].getContext("2d");
  less_favourable = parseInt(all_canvas[i].attributes["data-plot"].value);
  more_favourable = 100 - parseInt(all_canvas[i].attributes["data-plot"].value);
  pieData = [
    {
      value : less_favourable,
      color:"#FDC206",
      highlight: "#FEE082"
    },
    {
      value : more_favourable,
      color:"#82D23F",
      highlight: "#C0E89F"
    }    
  ]
  window.myPie = new Chart(ctx).Pie(pieData,{
    segmentShowStroke : true,
    animateRotate : true
  });
};