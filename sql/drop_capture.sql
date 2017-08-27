update locations
  set l_lid=:tomb, l_visible=0, l_bid=1-l_bid, l_pid=l_bpid
  where l_lid=:slid and l_lid<0
    and exists (
      select * from entrants 
      join users on u_uid=e_uid
      join boards on b_bid=l_bid and b_sid=e_sid
      join locations l on l.l_gid=locations.l_gid and l.l_bid=locations.l_bid and l.l_lid=:elid
      where locations.l_gid=e_gid and locations.l_bid=e_bid and u_value=:uid and e_gid=:gid);
