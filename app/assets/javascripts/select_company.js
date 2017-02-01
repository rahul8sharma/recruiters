//= require 'jquery'
//= require 'jquery-ui/jquery-ui'
//= require 'jquery-ui/jquery.datetimepicker.full.min'

// Get a date object for the current time
var defaultFrom = new Date();
// Set it to one month ago
defaultFrom.setMonth(defaultFrom.getMonth() - 1);
// Zero the hours
defaultFrom.setHours(0,0,0);

var defaultTo = new Date();

$(document).ready(function(){
  $(".datepicker.from").datetimepicker({
    format: 'd/m/Y',
    timepicker: false,
    maxDate: defaultTo,
    value: defaultFrom,
    startDate: defaultFrom
  });
  $(".datepicker.to").datetimepicker({
    format: 'd/m/Y',
    timepicker: false,
    maxDate: defaultTo,
    value: defaultTo,
    startDate: defaultTo
  });
  
  $(".export-link").on("click", function(){
    var start_date = $("#start_date").datetimepicker('getValue').toISOString();
    var end_date = $("#end_date").datetimepicker('getValue').toISOString();
    $(this).parent('form').find(".start_date").val(start_date);
    $(this).parent('form').find(".end_date").val(end_date);
    var confirmExport = confirm("Do you really want to export data for all the accounts?");
    if(confirmExport) {
      $(this).parent('form').submit();  
    }
  });
});

