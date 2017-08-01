select u_name as name, e_bid as board, e_sid as side from users
  join entrants on e_uid=u_uid
  where e_gid=:gid;
