// Split all tools names.
function splitToolsName(tools) {
  var toolsName = ''
  for(var toolIndex=0; toolIndex<tools.length; toolIndex++) {
    var lower = tools[toolIndex].split('_').join(' ')
    toolsName = toolsName + lower.charAt(0).toUpperCase() + lower.substr(1)
    if((tools.length - 1) != toolIndex) {
      toolsName = toolsName + ', '
    }
  }
  
  return toolsName
}

// Get all languages from psychometry tool congigurations.
function getlanguages(psychometry_tool) {
  let languages = ""
  if (psychometry_tool != null && psychometry_tool.languages.length != 0) {
    let toolLanguages = psychometry_tool.languages
    for(var toolIndex=0; toolIndex<toolLanguages.length; toolIndex++) {
      languages = languages + toolLanguages[toolIndex].text
      if((toolLanguages.length - 1) != toolIndex) {
        languages = languages + ', '
      }
    }
  }
  
  return languages
}

// Get canditade stage from psychometry tool congigurations.
function getPurpose(psychometry_tool) {
  let purpose = ""
  if (psychometry_tool != null && psychometry_tool.candidate_stage.length != 0) {
    purpose = psychometry_tool.candidate_stage.replace(/\b\w/g, l => l.toUpperCase())
  }
  
  return purpose
}

//Insert Blank where the cursor is
function insertAtCursor(myField, myValue) {
  //IE support
  if (document.selection) {
    myField.focus();
    sel = document.selection.createRange();
    sel.text = myValue;
  }
  // Microsoft Edge
  else if(window.navigator.userAgent.indexOf("Edge") > -1) {
    var startPos = myField.selectionStart; 
    var endPos = myField.selectionEnd; 

    myField.value = myField.value.substring(0, startPos)+ myValue 
    + myField.value.substring(endPos, myField.value.length); 
    
    var pos = startPos + myValue.length;
    myField.focus();
    myField.setSelectionRange(pos, pos);
  }
  //MOZILLA and others
  else if (myField.selectionStart || myField.selectionStart == '0') {
    var startPos = myField.selectionStart;
    var endPos = myField.selectionEnd;
    myField.value = myField.value.substring(0, startPos)
    + myValue
    + myField.value.substring(endPos, myField.value.length);
  } else {
    myField.value += myValue;
  }
};

export default { splitToolsName, getlanguages, getPurpose, insertAtCursor }