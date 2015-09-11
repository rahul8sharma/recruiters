$(document).ready(function(){
  $(".section").on("change", function(){
    $(".subsection_"+$(this).attr('section')).attr('disabled', !$(this).is(":checked"));
  });

  var parent = new Array();
  
  var parentNames = new Array();
  var childNames = new Array();
  
  var finalArray = new Array();
  
  parent = $('.parent');

  for(i = 0; i < parent.length; i++){
    parentNames.push($(parent[i]).children().find('input')[0].name);
    var childLength = $(parent[i]).children().find('input').length-1;

    finalArray[i] = new Array();
    
    if(childLength > 1){
      for (var j = 1; j <= childLength; j++) {
        childNames.push($(parent[i]).children().find('input')[j].name);
        
        finalArray[i][j] = $(parent[i]).children().find('input')[j].name

      };
    }
  }
  
  
  /*console.log(childNames);

  var holder1 = JSON.stringify(parentNames);
  var x = JSON.parse(holder1);*/

});


/*$('#generate_preview').on('click', function(){
  var form_data = {
    name: 'id', 
    value: 322
  };

  var config = $('#assessment_form').serialize();
  form_data['config'] = config;
  form_data['authenticity_token'] = $('input[name="authenticity_token"]').attr('value');

  $.ajax({ 
      type: "POST",
      url: "/companies/2/360/report_preview",
      data: form_data,
      dataType: 'json',
      success: function(data)
      {   
        $("#ReportPreview").html(data.content);
      },error: function(data) { 
        alert("error"); 
      }
    });
});*/