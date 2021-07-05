SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination$
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


--Looking at total cases vs total deaths
--shows likelihood of dying if you contact covid in India
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like 'India'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
SELECT location,date,total_cases,population,(total_cases/population)*100 AS DeathPercentage1
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'India'
ORDER BY 1,2

-- Looking at countries with highest Infection Rate compared to population
SELECT location,MAX(total_cases) AS HigestInfectionCount,population,(MAX(total_cases)/population)*100 AS InfectedPopulation
FROM PortfolioProject..CovidDeaths$
GROUP BY location,population
ORDER BY InfectedPopulation DESC


--Showing Countries with Highest Death Count per Population
SELECT location,MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS null
GROUP BY location
ORDER BY HighestDeathCount DESC

--Letsbreak thngs down by continent
--Showing the continent with Highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS not null
GROUP BY continent
ORDER BY HighestDeathCount DESC


--Global Numbers
SELECT date, sum(new_cases) AS total_cases ,SUM(CAST(new_deaths AS int)) AS total_deaths ,SUM(CAST(new_deaths AS int))/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS not null
GROUP BY date
ORDER BY 1,2 


--Total deaths and Total cases
SELECT sum(new_cases) AS total_cases ,SUM(CAST(new_deaths AS int)) AS total_deaths ,SUM(CAST(new_deaths AS int))/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS not null
--GROUP BY date
ORDER BY 1,2 


--joining both table covid death and covid vaccinations
SELECT *
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccination$ v
	On d.location = v.location
	and d.date = v.date

--looking at Total Population vs Vaccination
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccination$ v
	On d.location = v.location
	and d.date = v.date
WHERE d.continent IS not null
ORDER BY 2,3

--or
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(CONVERT(INT,v.new_vaccinations)) OVER (Partition by d.location)
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccination$ v
	On d.location = v.location
	and d.date = v.date
WHERE d.continent IS not null
ORDER BY 2,3


SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(CONVERT(INT,v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location)
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccination$ v
	On d.location = v.location
	and d.date = v.date
WHERE d.continent IS not null
ORDER BY 2,3


--use CTE
WITH PopvsVac (continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
AS
(
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(CONVERT(INT,v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location,d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccination$ v
	On d.location = v.location
	and d.date = v.date
WHERE d.continent IS not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS RPC
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentpopulationVaccinated
CREATE TABLE #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentpopulationVaccinated
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location,d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccination$ v
	On d.location = v.location
	and d.date = v.date

SELECT *,(RollingPeopleVaccinated/population)*100 AS RPC
FROM #PercentpopulationVaccinated


--creating view to store data for later visualization

CREATE View PercentPopulationVaccinated1 as
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(CONVERT(INT,v.new_vaccinations)) 
	OVER (Partition by d.location ORDER BY d.location,d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccination$ v
	On d.location = v.location
	and d.date = v.date
WHERE d.continent IS not null

 
SELECT *
FROM PercentPopulationVaccinated1