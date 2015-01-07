function jsonRequest(url, dataHash, success_callback_function, failure_callback_function) {
  $.ajax(url, {
    type: 'GET',
    data: dataHash,
    dataType: 'json',
    success: function(response) {
        success_callback_function(response);
    },
    error: function(response) {
        failure_callback_function(response);
    }
  });
}