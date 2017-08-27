select
    t_bid as board,
    b_cid as color,
    t_time as time,
    :now - (select MAX(t_timestamp) from turns t where turns.t_gid=t.t_gid and turns.t_bid=t.t_bid) as elapsed,
    (select COUNT(*) from turns t where t.t_gid=turns.t_gid and t.t_bid=turns.t_bid and t.t_turns<turns.t_turns) as lt,
    (select COUNT(*) from turns t where t.t_gid=turns.t_gid and t.t_bid=turns.t_bid and t.t_turns>turns.t_turns) as gt
  from turns 
  join entrants on t_gid=e_gid
  join users on e_uid=u_uid
  join boards on t_bid=b_bid and b_sid=t_sid
  join games on g_gid=t_gid
  where t_gid=:gid and t_timestamp IS NOT NULL and u_value=:uid and g_result is NULL;
