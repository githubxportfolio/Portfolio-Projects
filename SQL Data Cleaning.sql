-- Data cleaning 

-- Raw data from ourworldindata.org/covid-deaths

SELECT * FROM CovidDeaths

SELECT * FROM CovidVaccination

---------------------------------------------------------------------------------------------------------------------------- 

-- Count can be use for counting the length of the string 
-- Can be used on columns with for example: phone numbers or Social Security number to see if it is the right amount
with CTE_02(len) AS
(SELECT len(location)
from CovidDeaths )

SELECT distinct len
from CTE_02
order by 1

--or 

SELECT distinct len(location)
from CovidDeaths 
order by 1

---------------------------------------------------------------------------------------------------------------------------- 

/*	Date format.
	Getting just the date(yy-mm-dd) from the column called [date] that has the date and time.
	Making another column and show how to update just the date in the column.	*/

SELECT convert(date,date)
FROM CovidDeaths

SELECT "date without time"
FROM CovidDeaths

Alter Table CovidDeaths
ADD "date without time" date;

UPDATE CovidDeaths
SET "date without time" = convert(date,date)

----------------------------------------------------------------------------------------------------------------------------

/*  Joining strings or columns.
	Adding the new combined string into a newly created column. 
	Can be to put 2 separate first and last names into one single column */

SELECT CONCAT(continent, ' ' , location)
FROM CovidDeaths

Alter TABLE CovidDeaths
ADD "Combined Columns" nvarchar(255)

Update CovidDeaths
SET "Combined Columns" = CONCAT(continent, ' ' , location)

----------------------------------------------------------------------------------------------------------------------------

/*  Separating the [Combined Colomns] column into 2 columns (adding 2 more columns).
	An example is if we have a full name we can get 2 columns with first and last names separately  */

SELECT SUBSTRING("Combined Columns", 1 , CHARINDEX(' ',"Combined Columns")-1) AS "first"
FROM CovidDeaths

SELECT SUBSTRING("Combined Columns", CHARINDEX(' ',"Combined Columns")+1, LEN("Combined Columns")) AS "second"
FROM CovidDeaths

ALTER TABLE CovidDeaths
ADD "First Colomn" nvarchar(255)

UPDATE CovidDeaths
SET "First Colomn" = SUBSTRING("Combined Columns", 1 , CHARINDEX(' ',"Combined Columns")-1)

ALTER TABLE CovidDeaths
ADD "Second Column" nvarchar(255)

UPDATE CovidDeaths
SET "Second Column" = SUBSTRING("Combined Columns", CHARINDEX(' ',"Combined Columns")+1, LEN("Combined Columns"))

----------------------------------------------------------------------------------------------------------------------------

/* Another way to separate is using Parsename() */

SELECT * FROM CovidDeaths

SELECT PARSENAME(Replace("Combined Columns",' ','.'), 2), 
		PARSENAME(Replace("Combined Columns",' ','.'), 1)
FROM CovidDeaths

ALTER TABLE CovidDeaths
ADD "Second copy(1)" nvarchar(255)

UPDATE CovidDeaths
SET "Second copy(1)" = PARSENAME(Replace("Combined Columns",' ','.'), 2)

ALTER TABLE CovidDeaths
ADD "Second copy(2)" nvarchar(255)

UPDATE CovidDeaths
SET "Second copy(2)" =	PARSENAME(Replace("Combined Columns",' ','.'), 1)

----------------------------------------------------------------------------------------------------------------------------

/*	Dropping unnecessary Columns 
	Not suppose to be done on raw data, only done one things like views. Just demonstrating.
	Dropping the extra column that i made with the parsename section. */

ALTER TABLE CovidDeaths
DROP COLUMN "Second Copy(1)", "Second Copy(2)"

----------------------------------------------------------------------------------------------------------------------------

/* Copying all the information from one old table to a new table and as a result it created a new table*/

Select * into Copycoviddeaths
FROM CovidDeaths

----------------------------------------------------------------------------------------------------------------------------
/* Deleting duplicates */
Select * from Copycoviddeaths

ALTER TABLE Copycoviddeaths
ADD unique_id int IDENTITY (1,1)

DELETE FROM Copycoviddeaths
WHERE unique_id NOT IN (SELECT MIN(unique_id) 
						From Copycoviddeaths 
						GROUP BY continent,
								location,
								date, 
								population, 
								total_cases, 
								new_cases, 
								total_deaths,
								new_deaths)	

--OR Another Way is using row_number()

WITH CTE_1 AS
(
Select *, 
ROW_NUMBER() over (partition by continent ,
								location, 
								date, 
								population, 
								total_cases, 
								new_cases, 
								total_deaths, 
								new_deaths 
					ORDER BY continent ) as Rnk
FROM Copycoviddeaths
)
DELETE FROM CTE_1 
WHERE Rnk > 1

----------------------------------------------------------------------------------------------------------------------------


