var GAME = {
  ACTIVE : null,
  PIECE : null,
  CHESS_OFFSET : 9812,
  COLOR_OFFSET : { "W" : 0, "B" : 6 },
  DISPLAYS : [
    { "window": 400, "square": 20, "top": 6 },
    { "window": 650, "square": 30, "top": 6 },
    { "window": 900, "square": 40, "top": 6 },
    { "window": 1150, "square": 50, "top": 6 },
    { "window": 1400, "square": 60, "top": 6 },
    { "window": 1650, "square": 70, "top": 6 },
    { "window": 1900, "square": 80, "top": 6 }
  ],
  set_display : function() {
    var i = 1;
    for (; i < GAME.DISPLAYS.length; ++i) {
      if (window.innerWidth < DISPLAYS[i].window) {
        break;
      }
    }
    var display = GAME.DISPLAYS[i - 1];
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
  },
  param : function(s) { return new URLSearchParams(window.location.search).get(s); },
  get_td : function(bid, lid) {
    if (GAME.param("sid") == bid) {
      lid = 63 - lid;
    }
    if (GAME.param("bid") == "1") {
      bid = 1 - bid;
    }
    return document.getElementById("board"+bid+"_"+Math.floor(lid/8)+"_"+(lid%8));
  },
  get_center : function(bid, rid, text) {
    if (GAME.param("bid") == "1") {
      bid = 1 - bid;
    }
    return document.getElementById("board"+bid+"_"+rid+"_"+text);
  },
  populate_board : function(vc) {
    var v = vc.board;
    var c = vc.clocks;
    var n = vc.names;
    for (var b = 0; b < 2; ++b) {
      for (var i = 0; i < 64; ++i) {
        GAME.get_td(b, i).innerHTML = "";
      }
      for (var i = 1; i < 6; ++i) {
        GAME.get_center(b, i, "piece").innerHTML = "";
        GAME.get_center(b, i, "x").innerHTML = "";
        GAME.get_center(b, i, "count").innerHTML = "";
      }
    }
    for (var i = 0; i < v.length; ++i) {
      if (v[i]["square"] >= 0) {
        GAME.get_td(v[i]["board"], v[i]["square"]).innerHTML = "&#" + v[i]["piece"];
      } else if ((v[i]["piece"] - GAME.CHESS_OFFSET) % 6 != 0) {
        var j = (v[i]["piece"] - GAME.CHESS_OFFSET) % 6;
        var b = v[i]["board"];
        if (GAME.get_center(b, j, "count").innerHTML != "") {
          GAME.get_center(b, j, "count").innerHTML = parseInt(GAME.get_center(b, j, "count").innerHTML) + 1;
        } else if (GAME.get_center(b, j, "piece").innerHTML != "") {
          GAME.get_center(b, j, "x").innerHTML = "x";
          GAME.get_center(b, j, "count").innerHTML = "2";
        }
        GAME.get_center(b, j, "piece").innerHTML = "&#" + v[i]["piece"];
        GAME.get_center(b, j, "lid").value = v[i]["square"];
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
      if (GAME.param("sid") == c[i].board) {
        c[i].color = 1 - c[i].color;
      }
      GAME.get_center(c[i].board, c[i].color, "clock").innerHTML = text;
      GAME.get_center(c[i].board, c[i].color, "clock").style.fontWeight = fw;
    }
    for (var i = 0; i < n.length; ++i) {
      var sid = n[i].side == GAME.param("sid") ? 1 : 0;
      var bid = n[i].board == GAME.param("bid") ? 0 : 1;
      document.getElementById("board" + bid + "_" + sid + "_name").innerText = n[i].name;
    }
  },
  get_current_board : function() {
    var args = { "gid" : GAME.param("gid"), "uid" : USER.uid() }
    FUNCTIONAL.ajax("get_boards.json", "GET", args, null, GAME.populate_board);
  },
  resign : function() {
    var args = { "uid" : USER.uid(), "gid" : GAME.param("gid"), "bid": GAME.param("bid"), "sid": GAME.param("sid") };
    FUNCTIONAL.ajax("resign.json", "POST", args, null, function() { });
  },
  clear_active : function() {
    if (GAME.ACTIVE != null) {
      if (GAME.ACTIVE < 0) {
        document.getElementById(GAME.PIECE + "_piece").style.color=null;
      } else {
        GAME.get_td(GAME.param("bid"), GAME.ACTIVE).style.color=null;
      }
      GAME.ACTIVE = null;
      return true;
    }
    return false;
  },
  drop : function(name, piece) {
    GAME.clear_active();
  
    GAME.PIECE = name + "_" + piece;
    GAME.ACTIVE = document.getElementById(GAME.PIECE + "_lid").value;
    if (GAME.ACTIVE == "") {
      GAME.ACTIVE = null;
      return;
    }
    document.getElementById(GAME.PIECE + "_piece").style.color="red";
  },
  move : function(r, c) {
    var lid = 8 * r + c;
    if (GAME.param("sid") == GAME.param("bid")) {
      lid = 63 - lid;
    }
  
    var bid = GAME.param("bid");
    var sid = GAME.param("sid");
  
    var square = GAME.get_td(bid, lid);
    var piece_color = Math.floor(square.innerHTML.charCodeAt(0) / (GAME.CHESS_OFFSET + GAME.COLOR_OFFSET.B));
    // TODO: this is a bad way to get color, should get it via the boards table
    var player_color = (sid != bid);
    if (GAME.ACTIVE == null && square.innerHTML != "" && piece_color == player_color) {
      GAME.ACTIVE = lid;
      square.style.color="red";
    } else if (GAME.ACTIVE != null && GAME.ACTIVE < 0) {
      var args = { "uid" : USER.uid(), "gid" : GAME.param("gid"), "slid": GAME.ACTIVE, "elid": lid, "bid": bid, "sid": sid };
      FUNCTIONAL.ajax("drop.json", "POST", args, null, GAME.get_current_board);
      GAME.clear_active();
    } else if (GAME.ACTIVE != null) {
      var args = { "uid" : USER.uid(), "gid" : GAME.param("gid"), "slid": GAME.ACTIVE, "elid": lid, "bid": bid, "sid": sid }
      FUNCTIONAL.ajax("move.json", "POST", args, null, GAME.get_current_board);
      GAME.clear_active();
    }
  },
  setup : function() {
    GAME.set_display();
    var args = { "uid" : USER.uid() };
    FUNCTIONAL.ajax("new_user.json", "POST", args, null, USER.set_local_name);
    GAME.update();
  },
  update : function() {
    GAME.get_current_board();
    setTimeout(GAME.update, 1000);
  }
};

document.addEventListener("DOMContentLoaded", GAME.setup)
