Select *
From Project1..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From Project1..CovidVaccinations
--order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Project1..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project1..CovidDeaths
Where location like '%states%'
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Project1..CovidDeaths
Where location like '%states%'
Where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Project1..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's break things down by continent
-- Shwoing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by TotalDeathCount desc

-- Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Project1..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Project1..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


-- Vaccinations

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RunningTotalPeopleVaccinated
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RunningTotalPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RunningTotalPeopleVaccinated
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RunningTotalPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated bigint
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RunningTotalPeopleVaccinated
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RunningTotalPeopleVaccinated
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated