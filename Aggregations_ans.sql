/*
AGGREGATIONS:
The link to the exercise is given below:
https://pgexercises.com/questions/aggregates
*/

-- 1.
SELECT COUNT(*) FROM cd.facilities;

-- 2.
SELECT COUNT(*) FROM cd.facilities
WHERE guestcost>=10;

-- 3.
SELECT recommendedby, COUNT(*)
FROM cd.members
WHERE recommendedby is not NULL
GROUP BY recommendedby
ORDER BY recommendedby;

-- 4.
SELECT facid,
SUM(slots) AS TotalSlots
FROM cd.bookings
GROUP BY facid
ORDER BY facid;

-- 5.
SELECT facid,
SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE starttime>='2012-09-01' and starttime<'2012-10-01'
GROUP BY facid
ORDER BY SUM(slots);

-- 6.
-- SELECT EXTRACT(MONTH FROM starttime) AS month_number
-- FROM cd.bookings;

SELECT 
	facid,
	EXTRACT(MONTH FROM starttime) AS month,
	SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE EXTRACT(YEAR FROM starttime)=2012
GROUP BY facid, EXTRACT(MONTH FROM starttime)
ORDER BY facid, month;

-- 7.
SELECT COUNT(DISTINCT memid)
FROM cd.bookings;

-- Alternative:
select count(*) from 
	(select distinct memid from cd.bookings) as mems

-- 8.
SELECT
facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
HAVING SUM(slots)>1000
ORDER BY facid;

-- 9.
SELECT f.name,
SUM(slots*
   CASE WHEN memid=0 THEN f.guestcost
	ELSE f.membercost
END) AS revenue
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY f.name
ORDER BY revenue;

-- 10.
SELECT f.name,
SUM(slots*
   CASE WHEN memid=0 THEN f.guestcost
	ELSE f.membercost
END) AS revenue
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY f.name
HAVING SUM(slots*
   CASE WHEN memid=0 THEN f.guestcost
	ELSE f.membercost
END) < 1000
ORDER BY revenue;

-- Alternative:
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

-- 11.
WITH cte AS (
  SELECT facid, SUM(slots) AS sum_slots
  FROM cd.bookings
  GROUP BY facid)
 
SELECT facid, MAX(sum_slots) AS "Total Slots"
FROM cte
GROUP BY facid
ORDER BY MAX(sum_slots) desc LIMIT 1;

--Alternative:
WITH TotalSlots AS (
    SELECT facid, SUM(slots) AS total_slots
    FROM cd.bookings
    GROUP BY facid
)
SELECT facid, total_slots
FROM TotalSlots
WHERE total_slots = (SELECT MAX(total_slots) FROM TotalSlots);

-- Alternative:
SELECT facid, sum
FROM (
    SELECT facid, SUM(slots) AS sum
    FROM cd.bookings
    GROUP BY facid
) AS t
ORDER BY sum DESC
LIMIT 1;

-- 12.
SELECT 
    facid, 
    EXTRACT(MONTH FROM starttime) AS month,
    SUM(slots) AS total_slots
FROM 
    cd.bookings
WHERE 
    EXTRACT(YEAR FROM starttime) = 2012
GROUP BY 
    GROUPING SETS (
        (facid, EXTRACT(MONTH FROM starttime)),  -- Regular grouping by facid and month
        (facid),                                 -- Total per facility for all months
        ()                                       -- Total for all facilities and months
    )
ORDER BY 
    facid NULLS LAST, 
    month NULLS LAST;

/*
1. (facid, EXTRACT(MONTH FROM starttime)): This is the detailed grouping. The query will first group the data by facility (facid) and month (from the starttime column).

    Output: It gives the total number of slots for each facility in each month of 2012.
    (facid): This is a subtotal grouping. The query will next group the data only by facid (facility), regardless of the month.

    Output: It gives the total number of slots for each facility across all months of 2012.
    (): This is the grand total. The query will aggregate all rows without grouping by any column.

    Output: It gives the total number of slots booked across all facilities and all months.
*/

-- Alternative:
select facid, extract(month from starttime) as month, sum(slots) as slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
	group by rollup(facid, month)
order by facid, month;   

-- Using all UNION:
SELECT
facid, EXTRACT(MONTH FROM starttime) AS "month",
SUM(slots)
FROM cd.bookings
WHERE EXTRACT(YEAR FROM starttime)=2012
GROUP BY facid, EXTRACT(MONTH FROM starttime)

UNION

SELECT
facid, null AS "month",
SUM(slots)
FROM cd.bookings
WHERE EXTRACT(YEAR FROM starttime)=2012
GROUP BY facid

UNION

SELECT
null, null AS "month", SUM(slots)
FROM cd.bookings
ORDER BY facid, "month";

-- 13.
SELECT
f.facid, f.name, CAST(SUM(b.slots)/2 AS DECIMAL(10, 2)) AS "Total Hours"
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY (f.facid)
ORDER BY f.facid;


