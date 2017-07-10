select e_gid as gid, e_bid as bid, e_sid as sid
  from entrants
  join games on e_gid=g_gid
  join users on e_uid=u_uid
  where g_result is NULL and u_value=:uid;
