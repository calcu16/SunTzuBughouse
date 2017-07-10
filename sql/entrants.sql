select g_gid as gid, b_bid as bid, b_sid as sid, u_name as name
  from games
  join boards on b_bid < g_boards and b_sid < g_sides
  join entrants on e_gid = g_gid and e_bid = b_bid and e_sid = b_sid
  join users on e_uid = u_uid
  where (select count(*) from entrants e2 where e2.e_gid = gid)  < g_boards * g_sides;
