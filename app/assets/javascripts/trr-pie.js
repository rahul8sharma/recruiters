jQuery(function () {
  jQuery('.pie-chart').each(function(){
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
        colors: ["#82D23F","#FDC206"],
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
            name: 'Browser share',
            data: [
                ['Favorable', 100 - jQuery(this).data('percentage-candidates')],
                ['Less-Favorable', (jQuery(this).data('percentage-candidates'))]
            ]
        }]
    });    
  });
});

