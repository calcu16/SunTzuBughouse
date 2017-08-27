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
    FUNCTIONAL.ajax("join.json", "POST", args, null, function() {  window.location.replace("game.html?gid=" + gid + "&bid=" + bid + "&sid=" + sid); });
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
    var s = "random";
    var rs = document.getElementsByName("start");
    for (var i = 0; i < rs.length; ++i) {
      if (rs[i].checked) {
        s = rs[i].value;
      }
    }
    var args = { "timeControl": tcs, "visibility" : v };
    if (s == "random") ;
    else if (s == "colors") {
      args["mirror_color"] = "True";
    } else if (s == "teams") {
      args["mirror_team"] = "True";
    } else if (s == "boards") {
      args["mirror_board"] = "True";
    } else if (s == "everything") {
      args["mirror_color"] = "True";
      args["mirror_board"] = "True";
    } else if (s == "standard") {
      args["standard"] = "True";
    }
    FUNCTIONAL.ajax("new_game.json", "POST", args, null, LOBBY.get_open_games);
  },
  setup : function() {
    var args = { "uid" : USER.uid() };
    FUNCTIONAL.ajax("new_user.json", "POST", args, null, USER.set_local_name);

    LOBBY.update();
  },
  update : function() {
    LOBBY.get_open_games();
    setTimeout(LOBBY.update, 1000);
  }
}
document.addEventListener("DOMContentLoaded", LOBBY.setup)
