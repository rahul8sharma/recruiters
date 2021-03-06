//= require jquery-ui/jquery.datetimepicker.full.min
$(document).on('ready', function(){
  initDateTimePicker();  
});
function initDateTimePicker(){
  var date = new Date();
  var minutes = 1;
  var minTime = new Date(date.getTime()+minutes*60000);
  var d = new Date();
  var minDate = d.getDate() +"/"+ d.getMonth() +"/"+ d.getFullYear();
  var minTime = d.getHours() +":"+ d.getMinutes();

  if($('#datetimepicker').length > 0) {
    $("#datetimepicker").datetimepicker({
      minDate: minDate,
      minTime: minTime,
      step: 5,
      format:'d/m/Y H:i',
      onChangeDateTime:function(dp, $input){
        if ($input.val() == ""){
          $('#final-value').html(minDate+" at "+ minTime);
        }else{
          $('#final-value').html("on"+ $input.val().split(' ')[0]+" at "+$input.val().split(' ')[1]);
        }
      }
    });
    
    var displayDate = ($('#datetimepicker').val()).split(' ')[0];
    var displayTime = ($('#datetimepicker').val()).split(' ')[1];
    $('#final-value').html(minDate+" at "+ minTime);
  }
  
  if($('#datepicker').length > 0) {
    $("#datepicker").datetimepicker({
      startDate: minDate,
      timepicker: false,
      format:'d/m/Y'
    });
  }
}
