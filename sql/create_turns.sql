insert into turns (t_gid, t_bid, t_sid, t_pos, t_time, t_timestamp)
  select g_gid as t_gid, b_bid as t_bid, b_sid as t_sid, :pos as t_pos, g_time as t_time, NULL as t_timestamp
  from games
  join boards on b_bid=:bid and b_cid=:cid
  where g_gid=:gid;
