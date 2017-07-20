update locations
  set l_lid=:tomb, l_visible=0, l_bid=1-l_bid, l_pid=l_bpid
  where l_lid=:elid
    and exists (
      select * from entrants 
      join users on e_uid=u_uid and e_bid=l_bid
      join boards on b_bid=l_bid and e_sid=b_sid
      where l_gid=e_gid and u_value=:uid and e_gid=:gid);
