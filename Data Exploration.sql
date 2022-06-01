-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
FROM SQLDataExploration..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQLDataExploration..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract COVID-19 in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM SQLDataExploration..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

-- Looking at Total Cases vs. Population
-- Shows what percentage of population infected with COVID-19
SELECT location, date, population, total_cases, (total_cases / population) * 100 AS InfectedPercentage
FROM SQLDataExploration..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases / population) * 100 AS InfectedPercentage
FROM SQLDataExploration..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC

-- Showing Countries with Highest Death Count per Capita
SELECT location, MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM SQLDataExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT --

-- Showing Continents with the Highest Death Count per Capita
SELECT continent, MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM SQLDataExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS --

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM SQLDataExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total Population vs. Vaccinations
-- Shows Percentage of Population that has recieved at least one COVID-19 Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingTotalVaccinations
FROM SQLDataExploration..CovidDeaths dea
JOIN SQLDataExploration..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform calculation on PARTITION BY in previous query
With PopvsVac (continent, location, date, population, New_Vaccinations, RollingTotalVaccinations)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingTotalVaccinations
FROM SQLDataExploration..CovidDeaths dea
JOIN SQLDataExploration..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingTotalVaccinations / Population) * 100
FROM PopvsVac

-- Using TEMP TABLE to perform calculation on PARTITION BY in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingTotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingTotalVaccinations
FROM SQLDataExploration..CovidDeaths dea
JOIN SQLDataExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

SELECT *, (RollingTotalVaccinations / Population) * 100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingTotalVaccinations
FROM SQLDataExploration..CovidDeaths dea
Join SQLDataExploration..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated