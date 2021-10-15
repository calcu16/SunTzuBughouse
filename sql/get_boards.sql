select l_bid as board, l_lid as square, CASE WHEN l_cid = b_cid or l_visible or g_result is not NULL THEN l_pid + c_unicode_offset ELSE 63 END as piece
  from locations
  join colors on l_cid = c_cid
  join entrants on l_gid = e_gid
  join users on e_uid = u_uid
  join boards on l_bid = b_bid and b_sid = e_sid
  join games on g_gid = l_gid
  where l_gid=:gid and (u_value=:uid and (l_cid = b_cid or l_visible or l_blocking) or g_result is not NULL)
        and (l_cid>=0 or l_pid!=0) group by board, square, piece;
