CREATE TABLE games (
  g_gid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  g_boards INTEGER DEFAULT (2), -- Number of boards
  g_sides INTEGER DEFAULT (2), -- Number of sides in the game
  g_time INTEGER DEFAULT (300), -- Amount of time in a game
  g_delay INTEGER DEFAULT (0), -- Amount of time in a game
  g_visibility TEXT DEFAULT ('start'), -- When to update visibility 
  g_increment INTEGER DEFAULT (0), -- Amount of time in a game
  g_result INTEGER DEFAULT (NULL) -- The winner of the game (NULL for still in progress)
);

CREATE TABLE turns (
  t_gid INTEGER NOT NULL,
  t_bid INTEGER NOT NULL,
  t_sid INTEGER NOT NULL,
  t_turns INTEGER DEFAULT (0), -- number of moves made on a particular board in a game by a particular side
  t_time INTEGER,
  t_timestamp INTEGER, -- time of last move
  PRIMARY KEY (t_gid, t_bid, t_sid)
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
  p_name TEXT,
  p_min_drop INTEGER,
  p_max_drop INTEGER
);
INSERT INTO pieces VALUES (0, "K", "King", 0, 0);
INSERT INTO pieces VALUES (1, "Q", "Queen", 0, 64);
INSERT INTO pieces VALUES (2, "R", "Rook", 0, 64);
INSERT INTO pieces VALUES (3, "B", "Bishop", 0, 64);
INSERT INTO pieces VALUES (4, "N", "Knight", 0, 64);
INSERT INTO pieces VALUES (5, "P", "Pawn", 8, 56);

CREATE TABLE locations (
  l_gid INTEGER NOT NULL,
  l_bid INTEGER NOT NULL,
  l_lid INTEGER NOT NULL, -- negative means not currently on the board
  l_plid INTEGER DEFAULT (NULL), -- The previous location of the piece, NULL means no previous location
  l_move INTEGER DEFAULT (NULL), --The last move number for this piece, NULL if the piece has not moved
  l_shadow INTEGER DEFAULT (NULL), -- This pieces shadows another location (e.g. king during castles, pawn if en passant), NULL if this is the real piece
  l_pid INTEGER NOT NULL,
  l_bpid INTEGER NOT NULL,  -- The piece this was originally (used for captures after a promotion)
  l_cid INTEGER NOT NULL,
  l_visible INTEGER NOT NULL DEFAULT (0),
  PRIMARY KEY (l_gid, l_bid, l_lid, l_cid),
  FOREIGN KEY (l_gid) REFERENCES games (g_gid),
  FOREIGN KEY (l_pid) REFERENCES pieces (p_pid),
  FOREIGN KEY (l_bpid) REFERENCES pieces (p_pid),
  FOREIGN KEY (l_cid) REFERENCES colors (c_id)
);

CREATE TABLE record (
  r_rid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  r_gid INTEGER NOT NULL,
  r_cid INTEGER NOT NULL,
  r_sbid INTEGER NOT NULL,
  r_slid INTEGER NOT NULL,
  r_ebid INTEGER NOT NULL,
  r_elid INTEGER NOT NULL
);

CREATE TRIGGER record_move AFTER UPDATE ON locations FOR EACH ROW
  WHEN OLD.l_bid != NEW.l_bid or OLD.l_lid != NEW.l_lid
BEGIN
  INSERT INTO record (r_gid, r_cid, r_sbid, r_slid, r_ebid, r_elid)
    values (NEW.l_gid, OLD.l_cid, OLD.l_bid, OLD.l_lid, NEW.l_bid, NEW.l_lid);
END;

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
  FOREIGN KEY (e_uid) REFERENCES users (u_uid),
  FOREIGN KEY (e_bid) REFERENCES boards (b_bid)
);

CREATE TABLE moves (
  m_pid INTEGER NOT NULL,
  m_delta INTEGER NOT NULL, -- the change in row allowed
  m_range INTEGER NOT NULL DEFAULT (1), -- the maximum number of deltas allowed
  m_cid INTEGER DEFAULT (NULL), --  the color of the piece, NULL for either color
  m_move INTEGER NOT NULL DEFAULT (1), -- is this allowed for moving
  m_capture INTEGER NOT NULL DEFAULT (1), -- is this allowed for capturing
  m_min_lid INTEGER DEFAULT (0), -- the min location this is a valid move for
  m_max_lid INTEGER DEFAULT (64) -- the max location this is a valid move for
);

INSERT INTO moves (m_pid, m_delta) VALUES (0,  1);
INSERT INTO moves (m_pid, m_delta) VALUES (0, -1);
INSERT INTO moves (m_pid, m_delta) VALUES (0,  7);
INSERT INTO moves (m_pid, m_delta) VALUES (0, -7);
INSERT INTO moves (m_pid, m_delta) VALUES (0,  8);
INSERT INTO moves (m_pid, m_delta) VALUES (0, -8);
INSERT INTO moves (m_pid, m_delta) VALUES (0,  9);
INSERT INTO moves (m_pid, m_delta) VALUES (0, -9);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (1,  1, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (1, -1, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (1,  7, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (1, -7, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (1,  8, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (1, -8, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (1,  9, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (1, -9, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (2,  1, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (2, -1, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (2,  8, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (2, -8, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (3,  7, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (3, -7, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (3,  9, 8);
INSERT INTO moves (m_pid, m_delta, m_range) VALUES (3, -9, 8);
INSERT INTO moves (m_pid, m_delta) VALUES (4,  6 );
INSERT INTO moves (m_pid, m_delta) VALUES (4, -6 );
INSERT INTO moves (m_pid, m_delta) VALUES (4,  10);
INSERT INTO moves (m_pid, m_delta) VALUES (4, -10);
INSERT INTO moves (m_pid, m_delta) VALUES (4,  15);
INSERT INTO moves (m_pid, m_delta) VALUES (4, -15);
INSERT INTO moves (m_pid, m_delta) VALUES (4,  17);
INSERT INTO moves (m_pid, m_delta) VALUES (4, -17);
INSERT INTO moves (m_pid, m_delta, m_range, m_cid, m_move, m_capture) VALUES (5,  8, 1, 0, 1, 0);
INSERT INTO moves (m_pid, m_delta, m_range, m_cid, m_move, m_capture) VALUES (5,  9, 1, 0, 0, 1);
INSERT INTO moves (m_pid, m_delta, m_range, m_cid, m_move, m_capture) VALUES (5,  7, 1, 0, 0, 1);
INSERT INTO moves VALUES (5,  8, 2, 0, 1, 0, 8, 16);
INSERT INTO moves (m_pid, m_delta, m_range, m_cid, m_move, m_capture) VALUES (5, -8, 1, 1, 1, 0);
INSERT INTO moves (m_pid, m_delta, m_range, m_cid, m_move, m_capture) VALUES (5, -9, 1, 1, 0, 1);
INSERT INTO moves (m_pid, m_delta, m_range, m_cid, m_move, m_capture) VALUES (5, -7, 1, 1, 0, 1);
INSERT INTO moves VALUES (5,  -8, 2, 1, 1, 0, 48, 56);
