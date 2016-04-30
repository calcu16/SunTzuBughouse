select l_bid as board, l_lid as square, l_pid + c_unicode_offset as piece
  from locations
  join colors on l_cid = c_cid
  where l_gid=:gid and ((l_bid=0) != (l_cid=:team) or l_visible);
