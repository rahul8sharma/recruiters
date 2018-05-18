// Get the selected report json from report config.

function getSelectedReportConfig(reportConfig) {
  for(var k=0; k<reportConfig.length; k++) {
    if (reportConfig[k].selected) {
      reportConfig[k]["state"] = { "selected": true}
      delete reportConfig[k].opened
      delete reportConfig[k].selected
      delete reportConfig[k].value
      if (typeof reportConfig[k] == "object" && reportConfig[k].children != null) {getSelectedReportConfig(reportConfig[k].children);
      }
    } else {
      reportConfig.splice(k, 1);
      k = k - 1;
    }
  };
  return reportConfig;
}

// Deep merge of two array json.

var found = false;

function deepMerge(target, selected) {
  target.forEach( function (targetedItem) {
    found = false;
    var selectedItem = getObjectBykey(selected, targetedItem.id)
    if (selectedItem) {
      targetedItem['opened'] = true
      targetedItem['selected'] = true
    } else {
      targetedItem['opened'] = false
      targetedItem['selected'] = false
    }
    targetedItem['value'] = targetedItem.text
    if (typeof targetedItem == "object" && targetedItem.children != null) {
      deepMerge(targetedItem.children, selected);
    }
  });
  return target;
}

// Get json object by key.

function getObjectBykey(jsonObjects, id) {
  jsonObjects.forEach( function (jsonObject) {
    if(jsonObject.id === id) {
      found = true;
    } else if (typeof jsonObject == "object" && jsonObject.children != null && !found) {
      getObjectBykey(jsonObject.children, id);
    }
  });
  return found;
}

export default { deepMerge, getObjectBykey, getSelectedReportConfig }