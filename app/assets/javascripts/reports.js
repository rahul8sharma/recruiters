function number_pages() {
  var page_params = document.location.search.substring(1).split('&');
  var header = document.getElementsByClassName("header");
  if(page_params[0] == "page=1"){
    header[0].style.display = "none";
  }
  var current_page_divs = document.getElementsByClassName('current-page');
  for(var index=0; index < current_page_divs.length; ++index){
    current_page_divs[index].textContent = page_params[0].split("=")[1];
  }  
}

function validateEmail(email) { 
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
} 

function checkEmail(e){
  var email = document.getElementById("feedback_email").value;
  if(validateEmail(email)) {
    return true;
  }else {
    alert("Please enter a valid email address.");
    return false;
  }
}

window.onload = function(){
  number_pages();
}


