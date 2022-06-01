/*

Queries used for Tableau Project

*/


-- 1. 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM SQLDataExploration..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM SQLDataExploration..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- 3.

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM SQLDataExploration..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- 4.

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM SQLDataExploration..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC