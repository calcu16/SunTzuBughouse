update turns
  set t_turns=t_turns+1,
      t_time=t_time + (select MAX(t.t_timestamp) from turns t where t.t_gid=turns.t_gid and t.t_bid=turns.t_bid) - :now,
      t_timestamp=:now
  where t_gid=:gid and t_bid=:bid and t_sid=:sid
  and exists (
     select * from entrants 
     join users on e_uid=u_uid and e_bid=t_bid and e_sid=t_sid
     join boards on b_bid=e_bid
     where t_gid=e_gid and u_value=:uid
  )
;
