update locations
  set l_lid=:elid, l_pid=CASE WHEN
    l_pid=5 and CAST(:elid as INTEGER) >= 0 and CAST(:elid as INTEGER) < 8 or CAST(:elid as INTEGER) >= 56 and CAST(:elid as INTEGER) < 64
    THEN 1
    ELSE l_pid END
  where l_lid=:slid and l_gid=:gid and exists (
    select * from entrants 
  join users on u_uid=e_uid
  join boards on b_bid=l_bid and b_sid=e_sid and b_cid=l_cid
  where e_gid=l_gid and e_bid=l_bid and u_value=:uid);
