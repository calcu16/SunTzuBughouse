document.getStyleBySelectorText = function(name) {
  for (var i = 0; i < document.styleSheets.length; ++i) {
    var styleSheet = document.styleSheets[i];
    for (var j = 0; j < styleSheet.cssRules.length; ++j) {
      var rule = styleSheet.cssRules[j];
      if (rule.selectorText == name) {
        return rule.style;
      }
    }
  }
}
