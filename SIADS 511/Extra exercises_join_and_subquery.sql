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

-- How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).
select mems.firstname as memfname, mems.surname as memsname, recs.firstname as recfname, recs.surname as recsname
	from 
		cd.members mems
		left outer join cd.members recs
			on recs.memid = mems.recommendedby
order by memsname, memfname;      

-- How can you produce a list of all members who have used a tennis court? Include in your output the name of the court, and the name of the member formatted as a single column. 
-- Ensure no duplicate data, and order by the member name followed by the facility name.
select distinct mems.firstname || ' ' || mems.surname as member, faci.name as facility
  from 
    cd.members mems
	inner join cd.bookings bks
	  on mems.memid = bks.memid
	inner join cd.facilities faci
	   on bks.facid = faci.facid
  where 
    faci.name in ('Tennis Court 2','Tennis Court 1')
order by member, facility;

-- How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30? Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0. 
-- Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost, and do not use any subqueries.
select mems.firstname || ' ' || mems.surname as member, faci.name as facility,
  case
    when mems.memid=0 then
	  bks.slots*faci.guestcost
	else 
	  bks.slots*faci.membercost
  end as cost
  from 
    cd.members mems
	  inner join cd.bookings bks
	    on mems.memid=bks.memid
	  inner join cd.facilities faci
	    on bks.facid=faci.facid
  where 
    bks.starttime >= '2012-09-14' and
	bks.starttime < '2012-09-15' and (
	  (mems.memid = 0 and bks.slots*faci.guestcost > 30) or
	  (mems.memid != 0 and bks.slots*faci.membercost > 30)
	)
order by cost desc;

-- How can you output a list of all members, including the individual who recommended them (if any), without using any joins? 
-- Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
select distinct mems.firstname || ' ' || mems.surname as member, (select recs.firstname || ' ' || recs.surname as recommender from cd.members recs where recs.memid=mems.recommendedby)
from
  cd.members mems
order by member;

-- How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30? 
-- Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0. 
-- Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost.
select member, facility, cost from (
	select 
		mems.firstname || ' ' || mems.surname as member,
		facs.name as facility,
		case
			when mems.memid = 0 then
				bks.slots*facs.guestcost
			else
				bks.slots*facs.membercost
		end as cost
		from
			cd.members mems
			inner join cd.bookings bks
				on mems.memid = bks.memid
			inner join cd.facilities facs
				on bks.facid = facs.facid
		where
			bks.starttime >= '2012-09-14' and
			bks.starttime < '2012-09-15'
	) as bookings
	where cost > 30
order by cost desc;  



