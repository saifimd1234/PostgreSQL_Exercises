/*
STRINGS:
The link to the exercise is given below:
https://pgexercises.com/questions/string
*/

-- 1.
SELECT
CONCAT(surname, ', ', firstname) AS name
FROM cd.members;

-- 2.
SELECT *
FROM cd.facilities
WHERE name LIKE 'Tennis%';

-- 3.
SELECT *
FROM cd.facilities
WHERE lower(name) LIKE 'tennis%';

-- 4.
-- PostreSQL
SELECT memid, telephone 
FROM cd.members 
WHERE telephone ~ '[()]';

-- MySQL
SELECT memid, telephone 
FROM cd.members 
WHERE telephone REGEXP '[()]';

-- 5.
SELECT
lpad(cast(zipcode AS char(5)), 5, '0')
FROM cd.members

/*
1. SELECT lpad(...) AS zip
lpad(): This is a function that stands for "left pad." It is used to pad 
the left side of a string with a specified character until it reaches a 
certain length.

cast(zipcode as char(5)):
This part of the code converts the zipcode (which is likely an integer) 
to a string type (char(5)). This ensures that the ZIP code can be 
manipulated as a string for padding purposes.
If the zipcode is less than 5 digits long (for example, 123), casting it 
to char(5) would create a string representation of it.

2. lpad(cast(zipcode as char(5)), 5, '0')
Parameters:
The first parameter is the value to be padded (the casted zipcode).

The second parameter (5) is the total length the resulting string should have.

The third parameter ('0') specifies that the padding character is '0'.
Functionality:

If the zipcode is less than 5 characters long, lpad adds enough leading zeros ('0') to make it exactly 5 characters long. For example:

If zipcode = 123, the result after padding will be 00123.

If zipcode = 45678, it will remain 45678 since it is already 5 digits long.

If zipcode = 5, the result will be 00005.
*/

-- 6.
SELECT 
    UPPER(SUBSTR(surname, 1, 1)) AS first_letter, 
    COUNT(*) AS member_count
FROM 
    cd.members
GROUP BY 
    first_letter
ORDER BY 
    first_letter;

-- 7.
SELECT 
    memid, 
    translate(telephone, '-() ', '') AS telephone
FROM 
    cd.members
ORDER BY 
    memid;
 
 -- MySQL
 SELECT 
    memid, 
    REGEXP_REPLACE(telephone, '[-() ]', '') AS telephone
FROM 
    cd.members
ORDER BY 
    memid;

/*
This query is useful for normalizing telephone numbers by stripping away 
formatting characters, making it easier to store, search, or perform 
operations on the telephone numbers. The results will show each member's 
ID alongside their cleaned telephone number, sorted by their ID.
*/