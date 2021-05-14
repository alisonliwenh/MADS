-- Original source: https://pgexercises.com/

-- Retrieve the start time of members' bookings

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
---

-- How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.
select bks.starttime as start, facs.name as name
	from 
		cd.facilities facs
		inner join cd.bookings bks
			on facs.facid = bks.facid
	where 
		facs.name in ('Tennis Court 2','Tennis Court 1') and
		bks.starttime >= '2012-09-21' and
		bks.starttime < '2012-09-22'
order by bks.starttime;   

-- How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
select distinct recs.firstname as firstname, recs.surname as surname
	from 
		cd.members mems
		inner join cd.members recs
			on recs.memid = mems.recommendedby
order by surname, firstname;      
