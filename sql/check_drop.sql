select :elid
  from moves
  join locations sl on l_pid=m_pid
  join entrants on e_gid=l_gid and e_bid=l_bid
  join boards on b_bid=e_bid and b_cid=l_cid and b_sid=e_sid
  join games on g_gid=l_gid
  join turns on t_gid=l_gid and t_bid=b_bid and t_turns%%g_sides=b_cid
  join users on u_uid=e_uid
  join pieces on p_pid=l_pid
  where l_gid=:gid and u_value=:uid and l_lid=:slid
    and l_lid<0 and 0<=CAST(:elid as INTEGER) and CAST(:elid as INTEGER)<64
-- check that the drop is valid for the pieces
    and p_min_drop<=CAST(:elid as INTEGER) and CAST(:elid as INTEGER)<p_max_drop
-- make sure that we don't drop on our own piece or a piece we can see
    and not exists (select * from locations el where el.l_gid=sl.l_gid and el.l_bid=sl.l_bid and el.l_lid=:elid and (el.l_cid=sl.l_cid or el.l_visible))
    limit 1;
