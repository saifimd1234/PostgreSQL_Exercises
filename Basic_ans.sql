
/*
BASIC SELECT
The link to the exercise is given below:
https://pgexercises.com/questions/basic
*/
-- 1.
SELECT * FROM cd.facilities;

-- 2.
SELECT
name, membercost
FROM
cd.facilities;

-- 3.
SELECT *
FROM cd.facilities
WHERE membercost>0;

-- 4.
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost>0 AND membercost< monthlymaintenance/50;

-- 5.
SELECT
*
FROM cd.facilities
WHERE name LIKE '%Tennis%';

-- 6.
SELECT *
FROM
cd.facilities
WHERE facid IN (1,5);

-- 7.
SELECT
name,
CASE
    WHEN monthlymaintenance < 100 THEN 'cheap'
ELSE 'expensive'
END AS cost
FROM cd.facilities;

-- 8.
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate >= '2012-09-01';

-- 9.
SELECT DISTINCT surname
FROM cd.members
ORDER BY surname asc LIMIT 10;

-- 10.
SELECT surname
FROM cd.members
UNION
SELECT name
FROM cd.facilities;

-- 11.
SELECT
max(joindate) AS latest
FROM cd.members;

-- 12.
SELECT firstname, surname, joindate
FROM cd.members
WHERE joindate =
(
SELECT
MAX(joindate)
FROM cd.members);