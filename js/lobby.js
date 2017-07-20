var LOBBY = {
  get_open_games : function() {
    FUNCTIONAL.ajax("games.json", "GET", null, null, LOBBY.populate_games);
  },
  populate_games : function(v) {
    var gs = v["games"];
    var es = v["entrants"];
    var s = "";
  
    var enames = {};
    for (var i = 0; i < es.length; ++i) {
      enames[es[i]["gid"] + "," + es[i]["bid"] + "," + es[i]["sid"]] = es[i]["name"];
    }
  
    for (var i = 0; i < gs.length; ++i) {
      s += "<div id=\"game_" + gs[i]["gid"] + "\">";
      s += "Game: " + gs[i]["gid"];
      for (var j = 0; j < gs[i]["boards"]; ++j) {
        s += "<div id=\"board_" + gs[i]["gid"] + "_" + j + "\">";
        s += "Board: " + j;
        for (var k = 0; k < gs[i]["sides"]; ++k) {
          var key = gs[i]["gid"] + "," + j + "," + k;
          if (key in enames) {
            s += "<input type=\"button\" value=\"" + enames[key] + "\" disabled=\"true\"/>";
          } else {
            s += "<input type=\"button\" value=\"<empty>\" onclick=\"LOBBY.join_game('" + gs[i]["gid"] + "','" + j + "','" + k + "');\"/>";
          }
        }
        s += "</div>"
      }
      s += "</div>";
    }
    document.getElementById("open").innerHTML = s;
  
    var es = v["entrants"];
  },
  join_game : function(gid, bid, sid) {
    var args = { "uid" : localStorage.uid, "gid" : gid, "bid" : bid, "sid" : sid }
    FUNCTIONAL.ajax("join.json", "POST", args, null, active_game);
  },
  new_game: function() {
    var tc = document.getElementById("timeControl").value.split(":")
    var tcs = 0;
    for (var i = 0; i < tc.length; ++i) {
      tcs *= 60;
      tcs += parseInt(tc[i]);
    }
    var v = "start";
    var rv = document.getElementsByName("visibility");
    for (var i = 0; i < rv.length; ++i) {
      if (rv[i].checked) {
        v = rv[i].value;
      }
    }
    var args = { "timeControl": tcs, "visibility" : v };
    FUNCTIONAL.ajax("new_game.json", "POST", args, null, LOBBY.get_open_games);
  }
}
