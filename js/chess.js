var CHESS_OFFSET = 9812;
var COLOR_OFFSET = { "W" : 0, "B" : 6 };

var DISPLAYS = [
  { "window": 1400, "square": 60, "top": 6 },
];

function set_display() {
  var i = 1;
  for (; i < DISPLAYS.length; ++i) {
    if (window.innerWidth < DISPLAYS[i].window) {
      break;
    }
  }
  var display = DISPLAYS[i - 1];
  var style = document.getStyleBySelectorText("table.board td");
  var fontSize =  3 * display.square / 4;
  style.fontSize = fontSize + "px";
  style.height = display.square + "px";
  style.width = display.square + "px";
  
  style = document.getStyleBySelectorText("div.center");
  style.top = display.top + "px";

  style = document.getStyleBySelectorText("div.center div");
  style.height = display.square + "px";
  style.fontSize = fontSize + "px";
}

function get_td(bid, lid) {
  if (document.getElementById("sid").value == bid) {
    lid = 63 - lid;
  }
  if (document.getElementById("bid").value == "1") {
    bid = 1 - bid;
  }
  return document.getElementById("board"+bid+"_"+Math.floor(lid/8)+"_"+(lid%8));
}

function get_center(bid, rid, text) {
  if (document.getElementById("bid").value == "1") {
    bid = 1 - bid;
  }
  return document.getElementById("board"+bid+"_"+rid+"_"+text);
}

function populate_board(vc) {
  var v = vc.board;
  var c = vc.clocks;
  document.getElementById("game").style.display = "block";
  document.getElementById("lobby").style.display = "none";
  for (var b = 0; b < 2; ++b) {
    for (var i = 0; i < 64; ++i) {
      get_td(b, i).innerHTML = "";
    }
    for (var i = 1; i < 6; ++i) {
      get_center(b, i, "piece").innerHTML = "";
      get_center(b, i, "x").innerHTML = "";
      get_center(b, i, "count").innerHTML = "";
    }
  }
  for (var i = 0; i < v.length; ++i) {
    if (v[i]["square"] >= 0) {
      get_td(v[i]["board"], v[i]["square"]).innerHTML = "&#" + v[i]["piece"];
    } else if ((v[i]["piece"] - CHESS_OFFSET) % 6 != 0) {
      var j = (v[i]["piece"] - CHESS_OFFSET) % 6;
      var b = v[i]["board"];
      if (get_center(b, j, "count").innerHTML != "") {
        get_center(b, j, "count").innerHTML = parseInt(get_center(b, j, "count").innerHTML) + 1;
      } else if (get_center(b, j, "piece").innerHTML != "") {
        get_center(b, j, "x").innerHTML = "x";
        get_center(b, j, "count").innerHTML = "2";
      }
      get_center(b, j, "piece").innerHTML = "&#" + v[i]["piece"];
      get_center(b, j, "lid").value = v[i]["square"];
    }
  }
  for (var i = 0; i < c.length; ++i) {
    var fw = "normal";
    if (c[i].lt == 0 && c[i].gt == c[i].color) {
      c[i].time -= c[i].elapsed;
      fw = "bold";
    }
    var m = Math.floor(c[i].time / 60);
    var s = (c[i].time % 60) + "";
    if (s.length == 1) s = "0" + s;
    var text =  m + ":" + s;
    if (c[i].time < 0) {
      text = "FLAG";
    }
    if (document.getElementById("sid").value == c[i].board) {
      c[i].color = 1 - c[i].color;
    }
    get_center(c[i].board, c[i].color, "clock").innerHTML = text;
    get_center(c[i].board, c[i].color, "clock").style.fontWeight = fw;
  }
}

function get_current_board() {
  var args = { "gid" : document.getElementById("gid").value, "uid" : USER.uid() }
  FUNCTIONAL.ajax("get_boards.json", "GET", args, null, populate_board);
}

function set_active_game(result) {
  if (result !== null) {
    document.getElementById("gid").value = result.gid;
    document.getElementById("bid").value = result.bid;
    document.getElementById("sid").value = result.sid;
    get_current_board();
  } else {
    LOBBY.get_open_games();
  }
}

function active_game() {
  var args = { "uid" : USER.uid() };
  FUNCTIONAL.ajax("active_game.json", "GET", args, null, set_active_game);
}

var ACTIVE = null;
var PIECE = null;

function resign() {
  var bid = document.getElementById("bid").value;
  var sid = document.getElementById("sid").value;
  var args = { "uid" : USER.uid(), "gid" : document.getElementById("gid").value, "bid": bid, "sid": sid };
  FUNCTIONAL.ajax("resign.json", "POST", args, null, function() { });
}

function clear_active() {
  if (ACTIVE != null) {
    if (ACTIVE < 0) {
      document.getElementById(PIECE + "_piece").style.color=null;
    } else {
      get_td(document.getElementById("bid").value, ACTIVE).style.color=null;
    }
    ACTIVE = null;
    return true;
  }
  return false;
}

function drop(name, piece) {
  clear_active();

  PIECE = name + "_" + piece;
  ACTIVE = document.getElementById(PIECE + "_lid").value;
  if (ACTIVE == "") {
    ACTIVE = null;
    return;
  }
  document.getElementById(PIECE + "_piece").style.color="red";
}

function move(r, c) {
  var lid = 8 * r + c;
  if (document.getElementById("sid").value == document.getElementById("bid").value) {
    lid = 63 - lid;
  }

  var bid = document.getElementById("bid").value;
  var sid = document.getElementById("sid").value;

  var square = get_td(document.getElementById("bid").value, lid);
  var piece_color = Math.floor(square.innerHTML.charCodeAt(0) / (CHESS_OFFSET + COLOR_OFFSET.B));
  // TODO: this is a bad way to get color, should get it via the boards table
  var player_color = (document.getElementById("sid").value != document.getElementById("bid").value);
  if (ACTIVE == null && square.innerHTML != "" && piece_color == player_color) {
    ACTIVE = lid;
    square.style.color="red";
  } else if (ACTIVE != null && ACTIVE < 0) {
    var args = { "uid" : USER.uid(), "gid" : document.getElementById("gid").value, "slid": ACTIVE, "elid": lid, "bid": bid, "sid": sid };
    FUNCTIONAL.ajax("drop.json", "POST", args, null, get_current_board);
    clear_active();
  } else if (ACTIVE != null) {
    var args = { "uid" : USER.uid(), "gid" : document.getElementById("gid").value, "slid": ACTIVE, "elid": lid, "bid": bid, "sid": sid }
    FUNCTIONAL.ajax("move.json", "POST", args, null, get_current_board);
    clear_active();
  }
}

function setup() {
  set_display();

  var args = { "uid" : USER.uid() };
  var callback = FUNCTIONAL.andThen(USER.set_local_name, active_game);
  FUNCTIONAL.ajax("new_user.json", "POST", args, null, callback);

  update();
}

function update() {
  if (document.getElementById("gid").value == "") {
    LOBBY.get_open_games();
  } else {
    get_current_board();
  }
  setTimeout(update, 1000);
}

document.addEventListener("DOMContentLoaded", setup)
