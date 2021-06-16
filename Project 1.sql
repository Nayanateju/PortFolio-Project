select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations$
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Total Cases Vs Total Death--
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%' and  continent is not null
order by 1,2

--Total Cases Vs Population--
select location, date, total_cases,population, (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%states%'
order by 1,2

--countries with highest infection rate compared to population
select location,  max (total_cases) as highinfectionCount ,population, max((total_cases/population))*100 as PopulationPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location, population
order by PopulationPercentage desc

--Countries with highest death count 
select location, max(cast(total_deaths as int))as TotalDeathcount 
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathcount Desc

--Countries with highest death count per continent
select continent, max(cast(total_deaths as int))as TotalDeathcount 
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathcount Desc

-- GLobal Numbers for every continent--
select date,  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathPrecentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by Date
order by 1,2 desc

-- overall--
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathPrecentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2 desc

--Total population Vs vaccinations 
--1.-- Vaccinations per day--

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--2--rolling vaccination count--

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--creating CTE for calculating Total Popvsvacc--

with PopVsVac ( continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as PopVsVaccPercentage
from PopVsVac

--Temp Table
Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
Loaction nvarchar (255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentagePopulationVaccinated
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100 as PopVsVaccPercentage
from #PercentagePopulationVaccinated

--creating view for data visualization--
 
 CREATE VIEW PercentPopulationVaccinated 
 as
 select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
