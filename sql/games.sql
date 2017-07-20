select g_gid as gid, g_boards as boards, g_sides as sides
  from games
  where (select count(*) from entrants where e_gid = g_gid) < g_boards * g_sides and g_result is NULL;
