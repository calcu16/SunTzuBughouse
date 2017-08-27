update turns set t_timestamp=:now
  where t_gid=:gid and t_timestamp is NULL;
