
Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract in your country

Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%' and continent is not null
order by 1,2

--shows what percentage of population got into covid

Select location, date, total_cases,population,(total_deaths/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Looking at countries with highest Infection Rate compared to population

Select location, population , Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Showing Countries with highest death count per population

Select location, population, Max(cast(total_deaths as int)) as HighestdeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by HighestdeathCount desc

--Let's break things down by continent
Select continent, Max(cast(total_deaths as int)) as HighestdeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestdeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases,SUM(cast(total_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

Select * from PortfolioProject..CovidDeaths;

--Looking at total population vs vaccination

Select 
dea.continent,
dea.location,
dea.date,dea.population,
vac.new_vaccinations, 
sum(cast(new_vaccinations as bigint))over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac 
JOIN PortfolioProject..CovidDeaths dea 
ON dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
group by dea.date,dea.continent,dea.location,dea.population,vac.new_vaccinations
order by  dea.location,dea.date;

--Using CTE

with PopvsVac(continent, location, date, population, new_vaccinations, RollingpeopleVaccinated)
as
(
Select 
dea.continent,
dea.location,
dea.date,dea.population,
vac.new_vaccinations, 
sum(cast(new_vaccinations as bigint))over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac 
JOIN PortfolioProject..CovidDeaths dea 
ON dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
group by dea.date,dea.continent,dea.location,dea.population,vac.new_vaccinations
--order by  dea.location,dea.date
)
Select *, (RollingpeopleVaccinated/population)*100 as Percentage
from PopvsVac

--Temp Table
Create table #PercentPopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationvaccinated
Select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations, 
sum(cast(new_vaccinations as bigint))over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac 
JOIN PortfolioProject..CovidDeaths dea 
ON dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
group by dea.date,dea.continent,dea.location,dea.population,vac.new_vaccinations
--order by  dea.location,dea.date

Select *, (RollingpeopleVaccinated/population)*100 as Percentage
from #PercentPopulationvaccinated

--Creating View to store data for later visulaization

Create View PercentPopulationvaccinated as
Select 
dea.continent,
dea.location,
dea.date,dea.population,
vac.new_vaccinations, 
sum(cast(new_vaccinations as bigint))over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac 
JOIN PortfolioProject..CovidDeaths dea 
ON dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
group by dea.date,dea.continent,dea.location,dea.population,vac.new_vaccinations
--order by  dea.location,dea.date

--select from View table
Select * from PercentPopulationvaccinated;
