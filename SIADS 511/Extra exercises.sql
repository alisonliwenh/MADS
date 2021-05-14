-- Original source: https://pgexercises.com/questions/joins/simplejoin.html

-- Retrieve the start time of members' bookings
-- Question
-- How can you produce a list of the start times for bookings by members named 'David Farrell'?

select bks.starttime             -- give each table an alias (bks and mems)
  from 
    cd.bookings bks
    inner join cd.members mems
      on mems.memid = bks.memid
  where
    mems.firstname='David'
    and mems.surname='Farrell';
    
-- Give a table an alias for two reasons: 1. it's convenient; 2. we might joint to the same table several times, requiring us to distinguish between columns from each different time the table was joined in.

