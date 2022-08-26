--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--order by 3, 4

SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
order by 3, 4

-- Look at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPct
FROM PortfolioProject..CovidDeaths$
WHERE location like '%Mexico%'
order by 1, 2

-- Looking at Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases / population)*100 as PctCases
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Mexico'
order by 1, 2

-- Looking at countries with highest infection rates
SELECT location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases / population))*100 as PctPopulation
FROM PortfolioProject.dbo.CovidDeaths$
Group by location, population
order by 1 asc, 4 desc

-- Showing countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
Group by location
order by 2 desc

-- Showing continents with the highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is null 
Group by location
order by 2 desc

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PctDeaths
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY Date
order by 1


-- Loking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.Date) as RollingCount
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE

WITH PopVsVaccination (Contintent, location, Date, Population, New_vaccinations, RollingCount)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.Date) as RollingCount
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

Select *, (RollingCount/Population)*100
FROM PopVsVaccination

-- Createing view to sotre data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3

Select *
FROM PercentPopulationVaccinated