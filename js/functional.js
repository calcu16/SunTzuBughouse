var FUNCTIONAL = {
  encode_arguments : function(prefix, args) {
    var url = [];
    if (args === null) {
      return prefix;
    }
    for (var key in args) {
      if (args.hasOwnProperty(key)) {
        url.push(key + "=" + encodeURIComponent(args[key]));
      }
    }
    if (url.length > 0) {
      return prefix + "?" + url.join("&");
    } else {
      return 0;
    }
  },
  ajax : function(loc, type, args, data, callback) {
    var url = FUNCTIONAL.encode_arguments(loc, args);
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if (xhttp.readyState == 4 && xhttp.status == 200) {
        callback(JSON.parse(xhttp.responseText));
      }
    }

    xhttp.open(type, url, true);
    if (type == "POST") {
      xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    }
    xhttp.send(data);
  },
  andThen : function(lhs, rhs) {
    return function(arg) {
      return rhs(lhs(arg));
    }
  }
};

