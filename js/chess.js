function set_active_game(result) {
  if (result !== null) {
    window.location.replace("game.html?gid=" + result.gid + "&bid=" + result.bid + "&sid=" + result.sid);
  } else {
    window.location.replace("lobby.html");
  }
}

function active_game() {
  var args = { "uid" : USER.uid() };
  FUNCTIONAL.ajax("active_game.json", "GET", args, null, set_active_game);
}

function setup() {
  var args = { "uid" : USER.uid() };
  var callback = FUNCTIONAL.andThen(USER.set_local_name, active_game);
  FUNCTIONAL.ajax("new_user.json", "POST", args, null, callback);
}

document.addEventListener("DOMContentLoaded", setup)
