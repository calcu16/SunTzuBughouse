select (:elid-:slid)/m_delta as distance
  from moves
  join locations sl on l_pid=m_pid
  join entrants on e_gid=l_gid and e_bid=l_bid
  join boards on b_bid=e_bid and b_cid=l_cid and b_sid=e_sid
  join games on g_gid=l_gid
  join turns on t_gid=l_gid and t_bid=b_bid and t_sid=b_sid
  join users on u_uid=e_uid
  join pieces on p_pid=l_pid
  where l_gid=:gid and u_value=:uid and l_lid=:slid
    and (select COUNT(*) from turns t where t.t_gid=l_gid and t.t_bid=b_bid and t.t_turns<turns.t_turns)=0
    and (select COUNT(*) from turns t where t.t_gid=l_gid and t.t_bid=b_bid and t.t_turns>turns.t_turns)=b_cid
    and l_lid<64 and 0<=CAST(:elid as INTEGER) and CAST(:elid as INTEGER)<64 and
    ((0 <= l_lid
  -- check that the move is a valid direction and within range
      and (:elid-:slid)%%m_delta=0 and (:elid-:slid)/m_delta>0 and (:elid-:slid)/m_delta<=m_range
  -- check that the move is valid for the pieces current location and color (i.e. pawns can only move two from their second rank)
      and m_min_lid<=:slid and :slid<m_max_lid and (m_cid is null or m_cid=sl.l_cid)
      and (
  -- make sure we don't wrap around the outside of the board
           :elid%%8<:slid%%8 and (64+m_delta)%%8>4
        or :elid%%8=:slid%%8 and m_delta%%8=0
        or :elid%%8>:slid%%8 and (64+m_delta)%%8<4
      )
  -- make sure there are no pieces in between
      and not exists (
        select * from locations il
        where il.l_gid=sl.l_gid and il.l_bid=sl.l_bid and (il.l_lid-:slid)%%m_delta=0 and (il.l_lid-:slid)/m_delta>0 and (il.l_lid-:slid)/m_delta<(:elid-:slid)/m_delta
      )
  -- make sure (for pawns) that we can capture/not capture and still have a valid move
      and (
           (m_move=1 and not exists (select * from locations el where el.l_gid=sl.l_gid and el.l_bid=sl.l_bid and el.l_lid=:elid))
        or (m_capture=1 and exists (select * from locations el where el.l_gid=sl.l_gid and el.l_bid=sl.l_bid and el.l_lid=:elid and el.l_cid!=sl.l_cid))
      )
   ) or (
     l_lid < 0
     and p_min_drop<=CAST(:elid as INTEGER) and CAST(:elid as INTEGER)<p_max_drop
     and not exists (select * from locations el where el.l_gid=sl.l_gid and el.l_bid=sl.l_bid and el.l_lid=:elid and (el.l_cid=sl.l_cid or el.l_visible))
   ))
   limit 1;
