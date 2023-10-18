/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

-- This project was created at the end of my SQL certification course using COVID data from https://ourworldindata.org/covid-deaths. 
-- The goal of this project was to explore the data and pull out case/vaccination/death insights based on population and location.
-- Please note that the date span for this data is 2/24/2020 - 4/30/2021.
*/

SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent is not null
ORDER by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country

SELECT location,date,total_cases,total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage 
FROM CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT location,date,population,total_cases,(total_cases/population)*100 as PopulationInfectedPercentage 
FROM CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectedPercentage 
FROM CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER by PopulationInfectedPercentage DESC

--Showing Countries with the highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER by TotalDeathCount DESC

--Breaking things down by Continent
--Showing CONTINENTS with the Highest Death

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER by TotalDeathCount DESC

--Global Numbers

--Global Death percentage per day

SELECT date,SUM(New_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY Date
ORDER by 1,2

--Looking at the Total Population vs Vaccination
-- How many people in the world have been vaccinated?

--Using a CTE
WITH PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.Location = vac.Location 
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated/Population)*100 as PercentPopVaccinated
FROM PopvsVac

--Using a Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.Location = vac.Location 
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *,(RollingPeopleVaccinated/Population)*100 as PercentPopVaccinated
FROM #PercentPopulationVaccinated

--Creating Views to Store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.Location = vac.Location 
	and dea.date = vac.date
WHERE dea.continent is not null

