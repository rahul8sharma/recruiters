
$('a[name=AddStrategy]').click(function(){
  var html = $('.strategy').html().replace(/values\[[0-9]+\]/g, 'values['+strategiesCount+']');
  $('.StrategiesContainer').append(html);
  strategiesCount++;
});
