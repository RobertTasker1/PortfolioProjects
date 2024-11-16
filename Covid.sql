SELECT *
FROM Covid.CovidDeaths
WHERE Continent is NOT NULL
ORDER BY 3,4;

-- SELECT *
-- FROM Covid.CovidVaccinations
-- ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid.CovidDeaths
WHERE Continent is NOT NULL
ORDER BY 1,2 DESC;

-- Looking at Total Cases vs Total Deaths (death percentage)
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) DeathPercentage
FROM Covid.CovidDeaths
WHERE Location like '%states%' AND Continent is NOT NULL
ORDER BY 1,2 DESC;

-- Lookating at Total Cases vs Population
SELECT Location, date, population, total_cases, ROUND((total_cases/population)*100, 2) ContractionPercentage
FROM Covid.CovidDeaths
-- WHERE Location like '%states%'
WHERE Continent is NOT NULL
ORDER BY 1,2 DESC;

-- Looking at Countries with Highest Infection Rate vs Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(ROUND((total_cases/population)*100, 2)) HighestContractionPercentage
FROM Covid.CovidDeaths
-- WHERE Location like '%states%'
WHERE Continent is NOT NULL
GROUP BY Location, Population
ORDER BY HighestContractionPercentage DESC;

-- Looking at Countries with Highest Death Count
SELECT Location, population, MAX(cast(total_deaths AS unsigned integer)) AS HighestDeathCount
FROM Covid.CovidDeaths
WHERE Continent is NOT NULL OR continent = ""
GROUP BY Location, Population
ORDER BY HighestDeathPercentage DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Looking at Continents with Highest Death Count
SELECT continent, MAX(cast(total_deaths AS unsigned integer)) AS HighestDeathCount
FROM Covid.CovidDeaths
WHERE continent is NULL OR continent != ""
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- GLOBAL Daily NUMBERS
SELECT date, SUM(new_cases) AS Daily_New_Cases, SUM(cast(new_deaths AS signed integer)) AS Daily_New_Deaths, round(SUM(new_deaths)/SUM(new_cases)*100,2) AS Death_Percent
FROM Covid.CovidDeaths
WHERE Continent is NOT NULL
GROUP BY date
ORDER BY 1,2 DESC;

-- GLOBAL Total NUMBERS
SELECT SUM(new_cases) AS Total_New_Cases, SUM(cast(new_deaths AS signed integer)) AS Total_New_Deaths, round(SUM(new_deaths)/SUM(new_cases)*100,2) AS Death_Percent
FROM Covid.CovidDeaths
WHERE Continent is NOT NULL
ORDER BY 1,2 DESC;



-- Looking at Total Population vs Vaccinations, using a CTE to calculate Percent of Population Vaccinated
WITH pop_vac_cte AS(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date DESC) AS Rolling_Total_Vaccinations
FROM Covid.CovidDeaths AS cd
JOIN Covid.CovidVaccinations AS cv 
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent is NOT NULL
ORDER BY 2,3 DESC)

SELECT *, ROUND((pop_vac_cte.Rolling_Total_Vaccinations/pop_vac_cte.population)*100, 2) AS Pop_Percent_Vaccinated
FROM pop_vac_cte;



-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date DESC) AS Rolling_Total_Vaccinations
FROM Covid.CovidDeaths AS cd
JOIN Covid.CovidVaccinations AS cv 
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent is NOT NULL;









