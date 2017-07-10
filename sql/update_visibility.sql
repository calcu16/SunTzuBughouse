update locations
  set l_visible=exists (
    select * from locations sl
      join moves on m_pid=sl.l_pid
      join entrants on e_gid=l_gid and e_bid=locations.l_bid
      where
        locations.l_lid>=0
        and (locations.l_lid-sl.l_lid)%%m_delta=0 and (locations.l_lid-sl.l_lid)/m_delta>0 and (locations.l_lid-sl.l_lid)/m_delta<=m_range
        and m_min_lid<=sl.l_lid and sl.l_lid<m_max_lid and (m_cid is null or m_cid=sl.l_cid)
        and (
             locations.l_lid%%8<sl.l_lid%%8 and (64+m_delta)%%8>4
          or locations.l_lid%%8=sl.l_lid%%8 and m_delta%%8=0
          or locations.l_lid%%8>sl.l_lid%%8 and (64+m_delta)%%8<4
        )
        and not exists (
          select * from locations il
          where il.l_gid=sl.l_gid and il.l_bid=sl.l_bid and (il.l_lid-sl.l_lid)%%m_delta=0 and (il.l_lid-sl.l_lid)/m_delta>0 and (il.l_lid-sl.l_lid)/m_delta<(locations.l_lid-sl.l_lid)/m_delta
        )
        and locations.l_cid!=sl.l_cid and locations.l_bid=sl.l_bid
  )
  where l_gid=:gid
  and exists (
    select * from entrants 
    join users on e_uid=u_uid
    join boards on b_bid=l_bid and e_sid=b_sid and b_cid=l_cid
    where l_gid=e_gid and u_value=:uid
  );
