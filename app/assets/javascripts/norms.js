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
});
