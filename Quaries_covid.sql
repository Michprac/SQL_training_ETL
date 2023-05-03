--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
--where continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows probability of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%Poland%' and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population get Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
-- where location like '%Poland%'
where continent is not null
ORDER BY 1,2

-- Looking at Countries with Hieghest Infection Rate compared to population
SELECT location, population, MAX(total_cases) HighestInfectionCount,
MAX((total_cases/population)*100) as InfectedPercentage

FROM PortfolioProject..CovidDeaths
--where location like '%Poland%'
where continent is not null
GROUP BY location, population
ORDER BY InfectedPercentage desc




-- Showing Countrie with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount  
FROM PortfolioProject..CovidDeaths
--where location like '%Poland%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Let's break things down by continent
-- Showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount  
FROM PortfolioProject..CovidDeaths
--where location like '%Poland%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS Totals_cases, SUM(new_deaths) AS Totals_deaths,
	SUM(new_deaths)/ SUM(new_cases)*100 as DeathPercantage
FROM PortfolioProject..CovidDeaths
--where location like '%Poland%'
where continent is not null and new_cases != 0
--Group By date
ORDER BY 1,2


-- Linking two tables with each other
-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date ROWS UNbOUNDED PRECEDING) as RollingPeopleVaccinated 
--, (vac.new_vaccinations)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and 
	dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3

--USE CTE
with POPvsVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date ROWS UNbOUNDED PRECEDING) as RollingPeopleVaccinated 
--, (vac.new_vaccinations)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and 
	dea.date = vac.date
where dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100 

from POPvsVAC


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date ROWS UNbOUNDED PRECEDING) as RollingPeopleVaccinated 
--, (vac.new_vaccinations)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and 
	dea.date = vac.date
--where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date ROWS UNbOUNDED PRECEDING) as RollingPeopleVaccinated 
--, (vac.new_vaccinations)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and 
	dea.date = vac.date
where dea.continent is not null
--order by 2,3


SELECT *
FROm PercentPopulationVaccinated