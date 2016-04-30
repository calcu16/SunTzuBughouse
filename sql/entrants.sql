select e_bid as board, e_sid as side, u_name as name from entrants
  join users on u_uid = e_uid
  where e_gid = :gid;
