update games
  set g_result=:sid
  where g_gid=:gid and g_result is null
  and exists (
     select * from entrants 
     join users on e_uid=u_uid
     where g_gid=e_gid and u_value=:uid and e_sid=:sid
  );
