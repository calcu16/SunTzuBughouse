update games
  set g_result=(1-:sid)
  where g_gid=:gid and g_result is null
  and exists (
     select * from entrants 
     join users on e_uid=u_uid
     join boards on b_sid=e_sid
     join locations on l_gid=e_gid and l_bid=b_bid and l_cid=b_cid
     where g_gid=e_gid and u_value=:uid and e_sid=:sid and l_pid=0 and l_lid<0
  );
