jQuery(function () {
  jQuery('.pie-chart').each(function(){
    var positive_difference = parseFloat(jQuery(this).data('positive-percentage'));
    var negative_difference = parseFloat(jQuery(this).data('negative-percentage'));
    var aggrement_difference = parseFloat(jQuery(this).data('aggrement-percentage'));
    jQuery(this).highcharts({
        chart: {
          plotBackgroundColor: null,
          plotBorderWidth: null,
          plotShadow: false,
          backgroundColor: "",
          spacing: [5,5,5,5]
        },
        title: {
          text: ''
        },
        credits: {
          enabled: false
        },
        colors: ["#a3e7fc","#26c485","#553a41"],
        plotOptions: {
          pie: {
            animation: false,
            allowPointSelect: false,
            cursor: 'pointer',
            dataLabels: {
              enabled: true,
              format: '<b>{point.name}</b>: {point.percentage:.1f} %',
              style: {
                color: "black"
              }
            }
          }
        },
        series: [{
            type: 'pie',
            name: 'Perception Gap',
            data: [
                ['Perceived Positive Difference', positive_difference],
                ['Aggrement', aggrement_difference],
                ['Perceived Negative Difference', negative_difference]
            ]
        }]
    });    
  });
});

