select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using
select location,date,total_cases,new_cases, total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2
-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract
select location,date,total_cases, total_deaths,(cast(total_deaths as float)/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'

-- Looking at Total Cases vs Population
-- Shows what percentahe of population got Covid
select location,date,total_cases, total_deaths,population,(cast(total_deaths as float)/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select Location,Population, max(total_cases) as highestInfectionCount,max((cast(total_deaths as float)/population)*100) as PercentpopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- Looking at Countries with Highest Death Count per Population
select Location,max(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Let's break things down by continent

select location,max(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Global number
select sum(new_cases), sum (new_deaths), sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null --and cast(new_cases as int)!=0
--group by date
order by 1,2

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date
ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date
ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date
ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3

select *
from PercentPopulationVaccinated






