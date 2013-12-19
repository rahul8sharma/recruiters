function loadBenchmarkChart(factor_data){
  var arr = [
    ['Score', 'Frequency', { role: 'style' }]
  ];
  $.each(factor_data.scorePercentages, function(norm_bucket,scores){
    arr.push([norm_bucket, scores.score, "color:"+scores.color]);
  });
  var data = google.visualization.arrayToDataTable(arr);

  var options = {
    enableInteractivity: false,
    width:600, 
    height:300,
    hAxis: {
      baseline: 10,
      baselineColor: "#cccccc",
      minTextSpacing: 20, 
      textStyle: { 
        fontSize: 10 
      },
      titleTextStyle: { 
        fontSize:16 
      }, 
      slantedText: false, 
      title: "Score"
    },
    vAxis: {
      baseline: 0,
      baselineColor: "#cccccc",
      titleTextStyle: { 
        fontSize:16 
      }, 
      title: "Frequency", 
      gridlines: {
        color: "#ccc"
      },
      ticks: [
        {v:0, f: "0%"},
        {v:20, f: "20%"},
        {v:40, f: "40%"},
        {v:60, f: "60%"},
        {v:80, f: "80%"},
        {v:100, f: "100%"}
      ]
    },
    bar: {
      groupWidth: "70%"
    },
    legend: { 
      position: "none" 
    }
  };

  var chart = new google.visualization.ColumnChart(document.getElementById("benchmark-chart-"+factor_data.factorName));
  chart.draw(data, options);
}

function loadBenchmarkCharts(){ 
  $(".benchmark-chart").each(function(){
    var data = $(this).data();
    loadBenchmarkChart(data);
  });
}

$(document).ready(function(){
  setTimeout(function(){
    google.load('visualization', '1', {'callback':'loadBenchmarkCharts', 'packages':['corechart']});
  }, 2000);
});
