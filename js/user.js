var USER = {
  _random_hex_string : function(l) {
    var HEX = "0123456789ABCDEF";
    var s = "";
    for (var i = 0; i < l; ++i) {
      s += HEX.charAt(Math.floor(Math.random() * 16));
    }
    return s;
  },
  uid : function() {
    if (localStorage.getItem("uid") === null) {
      localStorage.uid = USER._random_hex_string(512);
    }
    return localStorage.uid;
  },
  set_local_name : function(result) {
    if (result.hasOwnProperty("name")) {
      document.getElementById("name").value = result.name;
    }
  },
  set_remote_name : function() {
    var args = { "uid" : localStorage.uid, "name" : document.getElementById("name").value };
    FUNCTIONAL.ajax("set_name.json", "POST", args, null, function(v){});
  }
};
