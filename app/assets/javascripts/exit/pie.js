jQuery(function () {
  jQuery('.pie-chart').each(function(){
    var colors = [];
    var data = $.map(jQuery(this).data(), function(option_data){
      var arr = [];
      arr.push(option_data.split("-:-")[0]);
      arr.push(parseFloat(option_data.split("-:-")[1]));
      colors.push(option_data.split("-:-")[2]);
      return [arr];
    });
    
    console.log(data);
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
        colors: colors,
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
            name: 'Percentages',
            data: data
        }]
    });    
  });
});

