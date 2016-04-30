CREATE TABLE games (
  g_gid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  g_boards INTEGER DEFAULT (2), -- Number of boards
  g_sides INTEGER DEFAULT (2), -- Number of sides in the game
  g_moves INTEGER DEFAULT (0) -- Number of moves played so far by any team
);

CREATE TABLE colors (
  c_cid INTEGER PRIMARY KEY,
  c_name TEXT,
  c_unicode_offset INTEGER
);
INSERT INTO colors VALUES (0, "White", 9812);
INSERT INTO colors VALUES (1, "Black", 9818);

CREATE TABLE boards (
  b_bid INTEGER NOT NULL,
  b_cid INTEGER NOT NULL,
  b_sid INTEGER NOT NULL,
  PRIMARY KEY (b_bid, b_cid),
  UNIQUE (b_bid, b_sid)
  FOREIGN KEY (b_cid) REFERENCES colors (c_cid)
);
INSERT INTO boards values (0, 0, 0);
INSERT INTO boards values (0, 1, 1);
INSERT INTO boards values (1, 0, 1);
INSERT INTO boards values (1, 1, 0);

CREATE TABLE pieces (
  p_pid INTEGER PRIMARY KEY,
  p_symbol TEXT,
  p_name TEXT
);
INSERT INTO pieces VALUES (0, "K", "King");
INSERT INTO pieces VALUES (1, "Q", "Queen");
INSERT INTO pieces VALUES (2, "R", "Rook");
INSERT INTO pieces VALUES (3, "B", "Bishop");
INSERT INTO pieces VALUES (4, "N", "Knight");
INSERT INTO pieces VALUES (5, "P", "Pawn");

CREATE TABLE locations (
  l_gid INTEGER NOT NULL,
  l_bid INTEGER NOT NULL,
  l_lid INTEGER NOT NULL, -- negative means not currently on the board
  l_plid INTEGER DEFAULT (NULL), -- The previous location of the piece, NULL means no previous location
  l_move INTEGER DEFAULT (NULL), --The last move number for this piece, NULL if the piece has not moved
  l_pid INTEGER NOT NULL,
  l_bpid INTEGER NOT NULL,  -- The piece this was originally (used for captures after a promotion)
  l_cid INTEGER NOT NULL,
  l_visible INTEGER NOT NULL DEFAULT (0),
  PRIMARY KEY (l_gid, l_bid, l_lid),
  FOREIGN KEY (l_gid) REFERENCES games (g_gid),
  FOREIGN KEY (l_pid) REFERENCES pieces (p_pid),
  FOREIGN KEY (l_bpid) REFERENCES pieces (p_pid),
  FOREIGN KEY (l_cid) REFERENCES colors (c_id)
);

CREATE TABLE users (
  u_uid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  u_value TEXT UNIQUE NOT NULL,
  u_name TEXT
);

CREATE TABLE entrants (
  e_gid INT NOT NULL,
  e_bid INT NOT NULL,
  e_sid INT NOT NULL,
  e_uid INT NOT NULL,
  PRIMARY KEY (e_gid, e_uid),
  UNIQUE (e_gid, e_bid, e_sid),
  FOREIGN KEY (e_gid) REFERENCES games (g_gid),
  FOREIGN KEY (e_uid) REFERENCES users (u_uid)
);

CREATE TABLE timers (
  t_gid INT NOT NULL,
  t_bid INT NOT NULL,
  t_sid INT NOT NULL,
  t_remaining NUMERIC NOT NULL,
  t_delta NUMERIC,
  PRIMARY KEY (t_gid, t_bid, t_sid),
  FOREIGN KEY (t_gid) REFERENCES games (g_gid)
);
