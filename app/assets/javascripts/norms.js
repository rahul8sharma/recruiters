/*
  This javascript is added to norms page while creating an assessment
  Checkboxes to select factors are disabled by default.
  On document ready  
  enable all checkboxes for factors
  Add change even on checkboxes to select factor
  On checked, enable all input tags under that factor_norm
  On Uncheck, if factor_norm is new then disable all input tags under that factor_norm, else mark as destroy
  Also toggle checked class for li tag for that factor
  
  For checkboxes to mark a factor as critical,
  on checked, set value of hidden critical field as on
  on uncheck, set value of hidden critical field as off
*/  

jQuery(document).ready(function($){
  $("input[name='selected_factor']").removeAttr("disabled");
  $("input[name='selected_factor']").change(function(){
    var index = $(this).attr("index");
    if($(this).is(":checked")){
      $("input:not(:checkbox)[index='"+index+"']").removeAttr("disabled");
      $("select[index='"+index+"']").removeAttr("disabled");
      $("#critical_checkbox_"+index).removeAttr("disabled");
      $("#li_"+index).addClass("checked");
    }else{
      var id = $("#id_"+index).val();
      if(id != null && id != ""){
        $("#destroy_"+index).val(true);
      }else{
        $("input:not(:checkbox)[index='"+index+"']").attr("disabled",'disabled');
        $("select[index='"+index+"']").attr("disabled",'disabled');
        $("#critical_checkbox_"+index).attr("disabled",'disabled');
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
  
  $("#check_all_fit0").change(function(){
    $(".check_fit0").prop("checked",$(this).is(":checked"));
    $(".check_fit0").trigger("change");
  });
  
  $("#check_all_fit1").change(function(){
    $(".check_fit1").prop("checked",$(this).is(":checked"));
    $(".check_fit1").trigger("change");
  });
  
  $("#check_all_fit2").change(function(){
    $(".check_fit2").prop("checked",$(this).is(":checked"));
    $(".check_fit2").trigger("change");
  });
});
