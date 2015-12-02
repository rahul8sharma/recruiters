$(document).ready(function(){
  $('.tabs a').on('click',function(){
    $('.tabs a').removeClass('active');
    $('.boxes div').removeClass('show');
    
    $(this).addClass('active');
    $('.'+ $(this).attr('class').split("_")[0]).addClass('show');
  })
});