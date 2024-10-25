/*
DATES:
The link to the exercise is given below:
https://pgexercises.com/questions/date
*/

-- 1.
SELECT timestamp '2012-08-31 01:00:00' as timestamp;

-- 2.
SELECT timestamp '2012-08-31 01:00:00' - timestamp '2012-07-30 01:00:00'AS interval;

-- 3.
SELECT
generate_series(timestamp '2012-10-01', timestamp '2012-10-31', interval '1 day') as ts

-- 4.
SELECT EXTRACT(DAY FROM timestamp '2012-08-31')

-- 5.
SELECT 
ROUND(EXTRACT(EPOCH FROM (timestamp '2012-09-02 00:00:00' - '2012-08-31 01:00:00'))) AS date_part

-- Alternative:
-- u can use timestamp in both places
SELECT 
ROUND(EXTRACT(EPOCH FROM (timestamp '2012-09-02 00:00:00' - timestamp '2012-08-31 01:00:00'))) AS date_part

-- 6.
WITH cte AS (
SELECT 
generate_series(timestamp '2012-01-01', timestamp '2012-12-01', interval '1 month') AS ts
  )
SELECT
EXTRACT(MONTH FROM ts) AS month,
(ts + INTERVAL '1 month' - ts) AS length
FROM cte

-- 7.
SELECT (DATE_TRUNC('month', ts.test) + INTERVAL '1 month')
  - DATE_TRUNC('day', ts.test) AS remaining
  FROM (SELECT timestamp '2012-02-11 01:00:00' AS test) ts;

  -- 8.
  SELECT
starttime,
starttime + slots*(interval '30 minutes') endtime
FROM cd.bookings
ORDER BY endtime desc, starttime desc
LIMIT 10;

-- 9.
SELECT 
DATE_TRUNC('MONTH', starttime) AS month, count(*)
FROM cd.bookings
GROUP BY month
ORDER BY month;

-- 10.
-- this question is pending