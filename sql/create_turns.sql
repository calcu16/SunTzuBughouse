insert or ignore into turns (t_gid, t_bid, t_sid, t_time, t_timestamp)
  select g_gid as t_gid, b_bid as t_bid, b_sid as t_sid, g_time as t_time, :now as t_timestamp
  from games
  join boards on b_bid<g_boards
  where g_gid=:gid;
