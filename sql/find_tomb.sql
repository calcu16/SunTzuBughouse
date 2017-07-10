select ifnull(lid, -1) as lid from (
  select max(l_lid - 1) as lid
  from locations l1
  join entrants on e_gid = l1.l_gid and e_bid = 1 - l1.l_bid
  join users on u_uid = e_uid
  where l_lid<0 and l_gid=:gid and u_value=:uid and not exists (
    select * from locations l2
    where l2.l_gid = l1.l_gid and l2.l_bid = l1.l_bid and l2.l_lid = l1.l_lid - 1
  )
);
