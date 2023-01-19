Select *
From PortfolioProject..CovidDeaths
Where Continent is not null
Order by 3,4


-- Select *
-- From PortfolioProject..CovidVaccinations
-- Order by 3,4


-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid19 in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%Canada%'
Order by 1,2


-- Look at to Total Cases vs Population
-- Shows what percentage of Population contracted Covi19
Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopInfected
From PortfolioProject..CovidDeaths
-- Where Location like '%Canada%'
Order by 1,2


-- Looking at Conuntries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopInfected
From PortfolioProject..CovidDeaths
-- Where Location like '%Canada%'
Group by Location, Population
Order by PercentPopInfected DESC


-- Showing countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where Location like '%Canada%'
Where Continent is not null
Group by Location
Order by TotalDeathCount DESC



-- Breakdown by Continent

Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where Location like '%Canada%'
Where Continent is not null
Group by Continent
Order by TotalDeathCount DESC


-- This is the way that Alex Freberg figured out is actually correct in his tutorial video

-- Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
-- From PortfolioProject..CovidDeaths
-- Where Location like '%Canada%'
-- Where Continent is null
-- Group by Location
-- Order by TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where Location like '%Canada%'
Where continent is not null
-- Group by date
Order by 1,2
-- If 'date' is removed from the query, the result will be the one total.


-- Looking at Total Population vs Vacinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/populations)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/populations)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingVaccinationCount/Population)*100
From PopvsVac


-- TEMP TABLE


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/populations)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- Where dea.continent is not null
--Order by 2,3

Select *, (RollingVaccinationCount/Population)*100
From #PercentPopulationVaccinated


-- Create View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/populations)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3


Select *
From PercentPopulationVaccinated