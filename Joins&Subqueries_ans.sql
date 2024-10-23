/*
BASIC SELECT
The link to the exercise is given below:
https://pgexercises.com/questions/joins
*/

-- 1.
SELECT
b.starttime
FROM cd.members m
INNER JOIN cd.bookings b
ON m.memid=b.memid
WHERE firstname='David' AND surname='Farrell';

-- 2.
-- How can you produce a list of the start times for bookings for tennis
-- courts, for the date '2012-09-21'? Return a list of start time and
--facility name pairings, ordered by the time.
SELECT b.starttime AS start, f.name
FROM cd.facilities f 
INNER JOIN cd.bookings b
ON f.facid=b.facid
WHERE f.name LIKE '%Tennis Court%' AND DATE(b.starttime)='2012-09-21'
ORDER BY b.starttime;

-- 2012-09-21 08:00:00  - suppose this is one of the start times
-- When we only provide the starttime='2012-09-21' the SQL engine autofill it
-- with the date '2012-09-21 00:00:00' to maintain the same granularity
-- but the exact date does not matches anyone as in the case above
-- Therefore, we have to pass it through the DATE() function
-- which picks only starttime as: 'YYYY-MM-DD'

-- 3.
SELECT firstname, surname
FROM cd.members
WHERE memid IN (
SELECT DISTINCT recommendedby
FROM cd.members)
ORDER BY surname, firstname;

-- Alternative
SELECT DISTINCT me.firstname, me.surname
FROM cd.members m
INNER JOIN cd.members me
ON m.recommendedby=me.memid
ORDER BY surname, firstname;

-- 4.
  SELECT
	m.firstname AS memfname,
	m.surname AS memsname,
	me.firstname AS recfname,
	me.surname AS recsname
FROM cd.members m
LEFT JOIN cd.members me
ON m.recommendedby=me.memid
ORDER BY memsname, memfname;

-- 5.
SELECT
	DISTINCT CONCAT(m.firstname,' ', m.surname) AS member,
	f.name AS facility
FROM cd.members m
INNER JOIN cd.bookings b
	ON m.memid=b.memid
INNER JOIN cd.facilities f
	ON b.facid=f.facid
WHERE f.name LIKE '%Tennis Court%'
ORDER BY member, facility;

-- 6.
WITH cte as (
  SELECT
	CONCAT(m.firstname,' ', m.surname) AS member,
	f.name AS facility,
	b.facid, b.memid, b.slots,
	f.membercost, f.guestcost,
  	b.slots*
  	CASE
  	WHEN b.memid=0 THEN f.guestcost
  	ELSE f.membercost
  	END AS cost
FROM cd.members m
INNER JOIN cd.bookings b
	ON m.memid=b.memid
INNER JOIN cd.facilities f
	ON b.facid=f.facid
WHERE DATE(b.starttime)='2012-09-14'
  ) 

SELECT member, facility, cost
FROM cte
WHERE cost>30
ORDER BY cost desc;

-- Alternative
select mems.firstname || ' ' || mems.surname as member, 
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
		bks.starttime < '2012-09-15' and (
			(mems.memid = 0 and bks.slots*facs.guestcost > 30) or
			(mems.memid != 0 and bks.slots*facs.membercost > 30)
		)
order by cost desc; 

-- 7.
SELECT 
DISTINCT CONCAT(firstname, ' ', surname) AS member,
(SELECT 
CONCAT(firstname, ' ', surname)
  FROM cd.members rec
WHERE rec.memid=m.recommendedby) AS recommender
FROM cd.members m
ORDER BY member, recommender;

-- 8.
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