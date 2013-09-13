function number_pages() {
  var page_params = document.location.search.substring(1).split('&');
  var header = document.getElementsByClassName("header");
  header.textContent = page_params[0];
  if(page_params[0] == "page=1"){
    header[0].style.display = "none";
  }
  var y = document.getElementsByClassName('current-page');
  for(var j=0; j < y.length; ++j){
    y[j].textContent = page_params[0].split("=")[1];
  }  
}

window.onload = function(){
  number_pages();
}
