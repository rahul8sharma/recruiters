/*
  This javascript is added to styles page while creating an assessment
  Checkboxes to select factors are disabled by default.
  On document ready  
  enable all checkboxes for factors
  Add change even on checkboxes to select factor
  On checked, enable all input tags under that factor_norm
  On Uncheck, if factor_norm is new then disable all input tags under that factor_norm, else mark as destroy
  Also toggle checked class for li tag for that factor_norm
  
  For checkboxes to mark a factor as critical,
  on checked, set value of hidden critical field as on
  on uncheck, set value of hidden critical field as off
*/

jQuery(document).ready(function($){
  $("input[name='selected_factor']").removeAttr("disabled");
  $("input[name='selected_factor']").change(function(){
    var index = $(this).attr("index");
    if($(this).is(":checked")){
      $("#li_"+index).addClass("checked");
      $("input:not(:checkbox)[index='"+index+"']").removeAttr("disabled");
    }else{
      var id = $("#id_"+index).val();
      if(id != null && id != ""){
        $("#destroy_"+index).val(true);
      }else{
        $("input:not(:checkbox)[index='"+index+"']").attr("disabled",'disabled');
        $("#li_"+index).removeClass("checked");
      }
    }
  });
  
  $("input[name='checkbox_critical']").change(function(){
    var index = $(this).attr("index");
    if($(this).is(":checked")){
      $("#critical_"+index).val("on");
    }else{
      $("#critical_"+index).val("off");
    }
  });
});
