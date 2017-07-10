update locations
  set l_lid=:elid
  where l_lid=:slid and l_gid=:gid and exists (
    select * from entrants 
  join users on u_uid=e_uid
  join boards on b_bid=l_bid and b_sid=e_sid and b_cid=l_cid
  where e_gid=l_gid and e_bid=l_bid and u_value=:uid);
