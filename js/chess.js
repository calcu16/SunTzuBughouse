CHESS_OFFSET = 9812;
COLOR_OFFSET = { "W" : 0, "B" : 6 };
PIECE_OFFSET = { "K" : 0, "Q" : 1, "R" : 2, "B" : 3, "N" : 4, "P" : 5 };

function ajax(url, type, data, callback) {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (xhttp.readyState == 4 && xhttp.status == 200) {
      callback(JSON.parse(xhttp.responseText));
    }
  }

  xhttp.open(type, url, true);
  xhttp.send(data);
}

function get_td_id(bid, sid) {
  return "board"+bid+"_"+Math.floor(sid/8)+"_"+(sid%8);
}

function populate_board(v) {
  for (var i = 0; i < v.length; ++i) {
    document.getElementById(get_td_id(v[i]["board"], v[i]["square"])).innerHTML = "&#" + v[i]["piece"];
  }
}

function populate_games(v) {
  var s = "";
  for (var i = 0; i < l; ++i) {
    s += "<div id=\"game" + v[i]["gid"] + "\">";
    s += "Game";
    s += "</div>";
  }
}

function random_hex_string(l) {
  var HEX = "0123456789ABCDEF";
  var s = "";
  for (var i = 0; i < l; ++i) {
    s += HEX.charAt(Math.floor(Math.random() * 16));
  }
  return s;
}

function setup() {
  if (localStorage.getItem("uid") === null) {
    localStorage.uid = random_hex_string(512);
    ajax("new_user.json?uid=" + random_hex_string, "GET", null, setup);
  }
  ajax("games.json", "GET", null, populate_games);
}

document.addEventListener("DOMContentLoaded", setup)

