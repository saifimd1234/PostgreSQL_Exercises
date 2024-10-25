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

-- table1.facid, table1.month, table1.slots
-- table2.facid, NULL,         table2.slots
-- NULL,         NULL,         table3.slots

-- 13.
SELECT
f.facid, f.name, CAST(SUM(b.slots)/2 AS DECIMAL(10, 2)) AS "Total Hours"
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY (f.facid)
ORDER BY f.facid;

/*
The above query looks correct but it is wrong because:
SUM(b.slots)/2 this returns integer and the SUM(slots) have odd numbers
which cannot be divided by 2.
*/

SELECT
b.facid, f.name,
ROUND(SUM(slots)/2.0, 2) AS "Total Hours"
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY b.facid, f.name
ORDER BY b.facid;

-- 14.
SELECT
m.surname, m.firstname, m.memid, MIN(starttime) AS starttime
FROM cd.bookings b
INNER JOIN cd.members m
ON m.memid=b.memid
WHERE b.starttime>'2012-09-01'
GROUP BY m.surname, m.firstname, m.memid
ORDER BY memid;

-- Alternative:
SELECT
m.surname, m.firstname, m.memid, MIN(starttime) AS starttime
FROM cd.bookings b
INNER JOIN cd.members m
ON m.memid=b.memid
WHERE b.starttime>'2012-09-01'
GROUP BY m.memid
ORDER BY memid;

-- You can only GROUP BY with memid bcz all the surnames and firstnames are the same

-- 15.
SELECT
COUNT(*) OVER() AS count,
firstname, surname
FROM cd.members;

-- Alternative:
select (select count(*) from cd.members) as count, firstname, surname
	from cd.members
order by joindate;

-- 16.
SELECT
ROW_NUMBER() OVER(ORDER BY joindate) AS row_number,
firstname, surname
FROM cd.members;

-- 17.
-- Using CTE:
WITH cte AS (
  SELECT
facid,
SUM(slots) AS total
FROM cd.bookings
GROUP BY facid
ORDER BY total desc
)
SELECT facid, total
FROM cte
WHERE total =
(SELECT MAX(total) FROM cte);

-- Using Subquery:
SELECT facid, total FROM (
SELECT
facid,
SUM(slots) AS total,
RANK() OVER(ORDER BY sum(slots) desc) AS rk
FROM cd.bookings
GROUP BY facid
ORDER BY total desc)t
WHERE rk=1;

-- 18.
-- USING WINDOWS RANK FUNCTION
SELECT
m.firstname, m.surname,
ROUND(SUM(b.slots)/2.0, -1) AS "hours", -- -1 is to round-off to the nearest tens
RANK() OVER(ORDER BY ROUND(SUM(b.slots)/2.0, -1) desc) AS rank
FROM cd.members m
INNER JOIN cd.bookings b
ON m.memid=b.memid
GROUP BY m.memid
ORDER BY rank, surname, firstname;

-- 19.
SELECT f.name,
RANK() OVER(ORDER BY SUM(CASE
	WHEN b.memid=0 THEN f.guestcost
	ELSE f.membercost
END * slots) desc) AS rank
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY f.facid, f.name
ORDER BY rank, f.name
LIMIT 3;

-- Alternative:
select name, rank from (
	select facs.name as name, rank() over (order by sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end) desc) as rank
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.name
	) as subq
	where rank <= 3
order by rank;   

-- USING CTE:
WITH cte AS (SELECT f.name,
SUM(CASE
WHEN b.memid=0 THEN f.guestcost
	ELSE f.membercost
END * b.slots) AS revenue
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY f.name
ORDER BY revenue desc
LIMIT 3)

SELECT name,
RANK() OVER(ORDER BY revenue desc) AS rank
FROM cte;

-- Alternative:
WITH cte AS
(SELECT f.name,
RANK() OVER(ORDER BY SUM(CASE
WHEN b.memid=0 THEN f.guestcost
	ELSE f.membercost
END * b.slots) desc) AS rank
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY f.name
ORDER BY rank)

SELECT * FROM cte 
WHERE rank<=3;

-- 20.
WITH cte AS
(SELECT
f.name,
NTILE(3) OVER(ORDER BY SUM(CASE
	WHEN b.memid=0 THEN f.guestcost
	ELSE f.membercost
END * b.slots) desc) AS ntile

FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY f.name)

SELECT name,
CASE
	WHEN ntile=1 THEN 'high'
	WHEN ntile=2 THEN 'average'
	ELSE 'low'
END AS revenue
FROM cte
ORDER BY ntile, name;

-- Alternative: USING SUBQUERIES:
select name, case when class=1 then 'high'
		when class=2 then 'average'
		else 'low'
		end revenue
	from (
		select facs.name as name, ntile(3) over (order by sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end) desc) as class
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.name
	) as subq
order by class, name;     

-- 21.
/*
Question:
Based on the 3 complete months of data so far, calculate the amount of 
time each facility will take to repay its cost of ownership. Remember to 
take into account ongoing monthly maintenance. Output facility name and 
payback time in months, order by facility name. Don't worry about 
differences in month lengths, we're only looking for a rough value here!
*/

-- Use the previous code to get the total revenue.
-- divide the total revenue by 3 to get monthly revenue.

-- initialoutlay / (monthly_revenue - monthlymaintenance)[investment/profit_per_month]

-- below query is correct but the order of operation is wrong
SELECT
f.name,
-- initialoutlay is first divided by SUM then the answer is again 
-- divided by 3 then monthlymaintenance is subtracted
f.initialoutlay/
SUM(CASE
	WHEN b.memid=0 THEN f.guestcost
	ELSE f.membercost
END * b.slots)/3.0 - f.monthlymaintenance AS months
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY f.name, f.monthlymaintenance, f.initialoutlay
ORDER BY f.name;

-- CORRECTED QUERY:
-- initialoutlay / (monthly_revenue - monthlymaintenance)[investment/profit_per_month]
SELECT
f.name,
f.initialoutlay/
(SUM(CASE
	WHEN b.memid=0 THEN f.guestcost
	ELSE f.membercost
END * b.slots)/3.0 - f.monthlymaintenance) AS months
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY f.name, f.monthlymaintenance, f.initialoutlay
ORDER BY f.name;

-- 22.
/*
Question:
For each day in August 2012, calculate a rolling average of total 
revenue over the previous 15 days. Output should contain date and 
revenue columns, sorted by the date. Remember to account for the 
possibility of a day having zero revenue. This one's a bit tough, so 
don't be afraid to check out the hint!
*/
SELECT
DATE(b.starttime),
AVG(SUM(CASE 
	WHEN b.memid=0 THEN f.guestcost
	ELSE f.membercost
END *b.slots)) OVER(ORDER BY DATE(b.starttime)
				   ROWS BETWEEN 14 PRECEDING
				   AND CURRENT ROW) as revenue
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
WHERE EXTRACT(MONTH FROM b.starttime)=8
GROUP BY DATE(b.starttime)
ORDER BY date

-- the above query is incorrect bcz of the place of WHERE filter
-- If we use WHERE there then the output is wrong bcz the table is
-- unaware of the previous 14 days to calculate the 1st AVG of 8th month.

-- CORRECTED QUERY:
WITH cte AS(

SELECT
DATE(b.starttime),
AVG(SUM(CASE 
	WHEN b.memid=0 THEN f.guestcost
	ELSE f.membercost
END *b.slots)) OVER(ORDER BY DATE(b.starttime)
				   ROWS BETWEEN 14 PRECEDING
				   AND CURRENT ROW) as revenue
FROM cd.bookings b
INNER JOIN cd.facilities f
ON b.facid=f.facid
GROUP BY DATE(b.starttime)
ORDER BY date)

SELECT *
FROM cte
WHERE DATE_TRUNC('MONTH', date) = '2012-08-01';