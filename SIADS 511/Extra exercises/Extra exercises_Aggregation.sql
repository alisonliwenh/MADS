-- For our first foray into aggregates, we're going to stick to something simple. We want to know how many facilities exist - simply produce a total count.
select count(*) from cd.facilities;

-- Produce a count of the number of facilities that have a cost to guests of 10 or more.
select count(*) from cd.facilities where guestcost >= 10;

-- Produce a count of the number of recommendations each member has made. Order by member ID.
select recommendedby, count(recommendedby) from cd.members where recommendedby is not null
group by recommendedby
order by recommendedby;

-- Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.
select 
  facid, sum(slots) as total
from 
  cd.bookings
group by facid
order by facid;

-- Produce a list of the total number of slots booked per facility in the month of September 2012. 
-- Produce an output table consisting of facility id and slots, sorted by the number of slots.
select facid, sum(slots) as "Total Slots"
  from  cd.bookings
  where 
    starttime >= '2012-09-01' and
    starttime < '2012-10-01'
  group by facid
order by sum(slots);

-- Produce a list of the total number of slots booked per facility per month in the year of 2012. 
-- Produce an output table consisting of facility id and slots, sorted by the id and month.
select facid, extract(month from starttime) as "month", sum(slots) as "Total Slots"
  from cd.bookings
  where 
    starttime >= '2012-01-01' and
	starttime < '2013-01-01'
  group by facid, month
order by facid, month;
-- Althernative solution
select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
	from cd.bookings
	where extract(year from starttime) = 2012
	group by facid, month
order by facid, month;

-- Find the total number of members (including guests) who have made at least one booking.
select count(memid) from cd.members
where memid in (select memid from cd.bookings);

-- Produce a list of facilities with more than 1000 slots booked. Produce an output table consisting of facility id and slots, sorted by facility id.
select facid, sum(slots) as "Total Slots"
  from cd.bookings
  group by facid
  having sum(slots) > 1000
  order by facid

-- Produce a list of facilities along with their total revenue. 
-- The output table should consist of facility name and revenue, sorted by revenue. Remember that there's a different cost for guests and members!
select facs.name, sum(slots * case
			when memid = 0 then facs.guestcost
			else facs.membercost
		end) as revenue
	from cd.bookings bks
	inner join cd.facilities facs
		on bks.facid = facs.facid
	group by facs.name
order by revenue;  

-- Produce a list of facilities with a total revenue less than 1000. Produce an output table consisting of facility name and revenue, sorted by revenue. 
-- Remember that there's a different cost for guests and members!
select name, revenue from (
	select facs.name, sum(case 
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end) as revenue
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.name
	) as agg where revenue < 1000
order by revenue; 

-- Output the facility id that has the highest number of slots booked. 
select facid, sum(slots) as "Total Slots"
  from cd.bookings
  group by facid
order by sum(slots) desc
limit 1;
-- Alternative solution without LIMIT clause
with sum as (select facid, sum(slots) as totalslots
	from cd.bookings
	group by facid
)
select facid, totalslots 
	from sum
	where totalslots = (select max(totalslots) from sum);

-- Produce a list of the total number of slots booked per facility per month in the year of 2012. 
-- In this version, include output rows containing totals for all months per facility, and a total for all months for all facilities. 
-- The output table should consist of facility id, month and slots, sorted by the id and month. 
-- When calculating the aggregated values for all months and all facids, return null values in the month and facid columns.
select facid, extract(month from starttime) as "month", sum(slots) as "slots"
  from cd.bookings
  where
    extract(year from starttime) = 2012
  group by rollup(facid, month)
order by facid, month;

-- Produce a list of the total number of hours booked per facility, remembering that a slot lasts half an hour. 
-- The output table should consist of the facility id, name, and hours booked, sorted by facility id. Try formatting the hours to two decimal places.
select faci.facid, faci.name, trim(to_char(sum(bks.slots)/2.0, '9999999999999999D99')) as "Total Hours"
-- The TO_CHAR function converts values to character strings.
-- The TRIM() function removes the longest string that contains a specific character from a string.
  from cd.bookings bks
  inner join cd.facilities faci
    on faci.facid=bks.facid
  group by faci.facid, faci.name
order by faci.facid;

					   
-- Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
select mems.surname, mems.firstname, mems.memid, min(bks.starttime) as starttime
  from cd.bookings bks
  inner join cd.members mems
    on mems.memid=bks.memid
  where starttime >= '2012=09=01'
  group by mems.surname, mems.firstname, mems.memid
order by mems.memid;
  
-- Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.
select count(*) over(), firstname, surname
from cd.members
order by joindate;

-- Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. 
-- Remember that member IDs are not guaranteed to be sequential.
select row_number() over (order by memid), firstname, surname
from cd.members
order by joindate;

-- Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.
select facid, total from (
	select facid, sum(slots) total, rank() over (order by sum(slots) desc) rank
        	from cd.bookings
		group by facid
	) as ranked
	where rank = 1   

