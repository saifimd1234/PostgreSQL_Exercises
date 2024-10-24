/*
MODIFYING DATA
The link to the exercise is given below:
https://pgexercises.com/questions/updates
*/

-- 1.
INSERT INTO cd.facilities(facid, name, membercost, guestcost,initialoutlay,monthlymaintenance)
VALUES(9,'Spa',20,30,100000,800);

-- 2.
-- NOTE: even if you insert multiple values, the keyword 'VALUES' is used only once
INSERT INTO cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES(9,'Spa',20,30,100000,800),
(10,'Squash Court 2', 3.5,17.5,5000,80);

-- 3.
INSERT INTO cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES((SELECT MAX(facid) FROM cd.facilities)+1,'Spa',20,30,100000,800);
-- the facid is auto incremented using the last facid value+1

-- 4.
UPDATE cd.facilities
SET initialoutlay=10000
WHERE name='Tennis Court 2';

-- 5.
UPDATE cd.facilities
SET membercost = 6, guestcost = 30
WHERE facid IN (0,1);

-- 6.
UPDATE cd.facilities
SET guestcost=
	ROUND((SELECT guestcost FROM cd.facilities WHERE name='Tennis Court 1')*110/100, 1),
	membercost=
	ROUND((SELECT membercost FROM cd.facilities WHERE name='Tennis Court 1')*110/100, 1)
WHERE name='Tennis Court 2';

-- Alternative:
update cd.facilities facs
    set
        membercost = (select membercost * 1.1 from cd.facilities where facid = 0),
        guestcost = (select guestcost * 1.1 from cd.facilities where facid = 0)
    where facs.facid = 1;    

-- 7.
DELETE FROM cd.bookings;

-- 8.
DELETE FROM cd.members 
WHERE memid=37;

-- 9.
DELETE FROM cd.members
WHERE memid NOT IN (SELECT memid FROM cd.bookings);

-- Alternative:
delete from cd.members mems where not exists (select 1 from cd.bookings where memid = mems.memid);
-- An alternative is to use a correlated subquery. Where our previous 
-- example runs a large subquery once, the correlated approach instead 
-- specifies a smaller subqueryto run against every row.