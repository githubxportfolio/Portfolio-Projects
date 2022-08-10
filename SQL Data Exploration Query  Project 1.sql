-- Exploring Data 

--Raw data from ourworldindata.org/covid-deaths
------------------------------------------------------------------------------
-

--Checking all the date from two tables (side note : will be using this a lot to check numbers, rows and columns)
SELECT * 
FROM CovidDeaths;

SELECT *
FROM CovidVaccination


-- Just to see the different countries without duplicates and how many countries there are (you can see how many at the botton right corner in SSMS, will show as rows)
SELECT Distinct location as "Different Countries"
FROM CovidDeaths;


--Exacting info in order
SELECT location, date, total_cases, total_deaths, population 
FROM CovidDeaths
Order by 1,2;


--Total cases vs Total Deaths in United States
SELECT location, 
		date, total_cases,
		total_deaths, 
		(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%' 
Order by 1,2;



--death over populaton rate in USA
SELECT location, 
		date, 
		population,
		total_deaths, 
		(total_deaths/population)*100 as DeathPercentage_over_pop
FROM CovidDeaths
WHERE location like '%states%' 
Order by 1,2;



-- Daily new cases over population of United states 
SELECT location, 
		date, 
		new_cases, 
		population, 
		(new_cases/population)*100 as "DailyInfectPercentage"
FROM CovidDeaths
WHERE location like '%states%'
Order by 1,2;



--Showing every location and their percentage of death over total cases
SELECT location, ((max(total_deaths))/(max(total_cases)))*100 as "death rate"
FROM CovidDeaths
GROUP BY location
order by [death rate] DESC


--*
--Countries with the highest infection rate over population.
SELECT Location,
		population, 
		max(total_cases) as " Infected cases",  
		((max(total_cases)/max(population))*100) as "Infected Percentage"
FROM CovidDeaths
WHERE continent is not null 
GROUP BY location, population
Order by [Infected Percentage] desc;




--Continent with the highest deaths
SELECT continent , max(cast(total_deaths as bigint)) as "Death Count"
FROM CovidDeaths
WHERE continent is not null 
GROUP BY continent
Order by [Death Count] desc


--*
--Total number of cases, deaths and deathpercentage
--*There are continents in the "location" column that has null in the "continent column so they are filtered out. 
--*Only want those that are not null in continent other wise it will overlap causing false numberes in other columns.
--Some columns doesnt have the right data type or number of bit was too high. Imported directly from the websites. Must use cast to get int or bigint for correction.
SELECT  SUM(new_cases) as "total cases", 
		SUM(cast(new_deaths as bigint)) as "total death", 
		(sum(cast(new_deaths as bigint))/sum(new_cases))*100 as "DeathPercentage"
FROM CovidDeaths
where continent is not null 



-- Checking out total cases over total death in United States
SELECT SUM(new_cases), 
		SUM(cast(new_deaths as int)), 
		(sum(cast(new_deaths as int))/sum(new_cases))*100 as "DeathPercentage"
FROM CovidDeaths
where continent is not null and location like '%states%'

 
 -- Using over() to get the rolling sum of numbers of people that were tested
 Select location, date,  new_tests, sum(cast(new_tests as bigint)) over (partition by location order by location, date ) as "Rolling sum of Tested people"
 from CovidVaccination
 where (new_tests is not null) 
 order by location, date, new_tests
 


--Total test in the each country (using sum)
SELECT  SUM(cast(vacc.new_tests as bigint))  as newtests, 
		death.location, 
		death.population 
FROM CovidDeaths death
join CovidVaccination vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null 
GROUP BY death.location, death.population
HAVING SUM(cast(vacc.new_tests as bigint)) is not null
order by death.location, death.population


--*
--Total deaths in each country (found a few that doesnt belong in "location" so i extract it)
SELECT location, SUM(cast(new_deaths as bigint)) as "Total Death Count"
FROM CovidDeaths
WHERE continent is not null 
	 and location not in ('world', 'upper middle income', 'lower middle income', 'high income', 'low income', 'international', 'european union' )
GROUP BY location
order by 2 desc


--
-- Total vaccinated people in the population of each country 
SELECT  death.location, max(vacc.people_vaccinated) as "people vaccinated"
FROM CovidDeaths death
JOIN CovidVaccination vacc
	on death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not null and vacc.people_vaccinated is not null
group by death.location
order by death.location;


--
--The first infection discovery date in each country 
WITH B_CTE as
	(SELECT location,  min(date) as "First date"
	FROM CovidDeaths
	where new_cases is not null and new_cases <> 0
	GROUP BY location)

 SELECT location, [First date] FROM B_CTE
 order by 2



 -- just checking how many of the same dates are in the data  
 Select date, count(date) from CovidDeaths
--where location like '%state%'
group by date
having count(date) >1
order by date
