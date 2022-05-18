--Data Exploration 2

--Raw data from ourworldindata.org/covid-deaths

SELECT * FROM CovidDeaths

SELECT * FROM CovidVaccination



-- Any country with capital "A" in its first name.
Select * 
FROM CovidDeaths
WHERE UPPER(location) like 'A%'



--total death count in between 10000 and 100000 and their respective countries and population 
--need to exclude some words that doesnt belong in location which is suppose to just be countries and not continents or other things...
Select location, 
		population, 
		max(cast(total_deaths as bigint)) AS max_death
FROM CovidDeaths
group by location, population
having  max(cast(total_deaths as bigint)) between 10000 and 100000
order by 3 desc


--death over population in each country using cte
WITH CTE_avg (loc, pop, max_death) as
(
Select location, 
		population, 
		max(cast(total_deaths as bigint)) as max_death
FROM CovidDeaths
where location not in ('World', 'Asia','Lower middle income','Upper middle income', 'High income','European Union','Europe','North America','South America')
group by location, population
)
SELECT loc, 
		pop, 
		(max_death/pop)*100 as "death percentage in each country"
FROM CTE_avg 
where ((max_death/pop)*100) is not null
order by 3 desc



--get the country with the highest population 
--need to exclude some words that doesnt belong in location which is suppose to just be countries and not continents or other things...
SELECT  location, 
		max(population) 
FROM CovidDeaths
where population = (SELECT max(population) from CovidDeaths where location not in ('World', 'Asia','Lower middle income','Upper middle income'))
GROUP BY location

--OR another way

SELECT TOP 1 location, 
			population
FROM CovidDeaths
where location not in ('World', 'Asia','Lower middle income','Upper middle income')
ORDER BY population desc


--need to exclude some words that doesnt belong in location which is suppose to just be countries and not continents or other things...
--Get the 2nd highest population and the country name
SELECT top 1 location,  
			max(population)
FROM CovidDeaths
WHERE population <> (SELECT max(population) FROM CovidDeaths where location not in ('World', 'Asia','Lower middle income','Upper middle income')) and location not in ('World', 'Asia','Lower middle income','Upper middle income')
group by location
ORDER BY MAX(population) desc


--Using window functions
--Find the nth highest population (47th in this case). Give the country name and population as well.
WITH cte_densernk as
(
SELECT  location, 
		population, 
		dense_rank() over (order by population desc) AS  rnk
FROM CovidDeaths 
where population is not null and location not in ('World', 'Asia','Lower middle income','Upper middle income')
group by location, population 
)
SELECT * 
FROM cte_densernk
WHERE rnk = 47



--Using row_number
WITH cte_rank as
(
SELECT  location, 
		population, 
		row_number() over (order by population desc) AS  rnk
FROM CovidDeaths 
where population is not null and location not in ('World', 'Asia','Lower middle income','Upper middle income')
group by location, population 
)
SELECT * 
FROM cte_rank
--WHERE rnk = 47