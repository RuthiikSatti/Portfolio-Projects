select *
from projectportfolio..CovidDeaths
where continent is not null
order by 3,4


-- looking at total cases vs deaths
-- shows the likelyhood of dying if you contract covid in your country
SELECT location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths) / (total_cases) * 100 AS DeathPercentage
FROM projectportfolio..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2 


-- total cases vs pop
SELECT location, date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM projectportfolio..CovidDeaths
order by 1,2


--looking at countries at highesst invection rate
SELECT location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 AS DeathPercentage
FROM projectportfolio..CovidDeaths
--where location like '%states&'
group by location, population
order by DeathPercentage desc


--deaths in country
SELECT location, max(cast(total_deaths as int)) as totaldeath
FROM projectportfolio..CovidDeaths
--where location like '%states&'
where continent is not null
group by location
order by totaldeath desc



-- show continents with highest deathcount
SELECT continent, max(cast(total_deaths as int)) as totaldeath
FROM projectportfolio..CovidDeaths
--where location like '%states&'
where continent is not null
group by continent
order by totaldeath desc


 -- cases, death and percentage by date
SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
FROM projectportfolio..CovidDeaths
--where location like '%India%'
where continent is not null
group by date
order by 1,2

 -- cases, death and percentage
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
FROM projectportfolio..CovidDeaths
--where location like '%India%'
where continent is not null
order by 1,2


-- total pop vs vaccination
with popvsvac (continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT (bigint, V.new_vaccinations)) OVER (Partition by D.location Order by D.location,D.date) as RollingPeopleVaccinated
From CovidDeaths D
Join CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 from popvsvac


--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #percentpopulationvaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT (bigint, V.new_vaccinations)) OVER (Partition by D.location Order by D.location,D.date) as RollingPeopleVaccinated
From CovidDeaths D
Join CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
--where D.continent is not null
select *, (RollingPeopleVaccinated/population)*100 from #percentpopulationvaccinated


-- create view to0 dtore data for later visualixation

create view percentpopulationvaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT (bigint, V.new_vaccinations)) OVER (Partition by D.location Order by D.location,D.date) as RollingPeopleVaccinated
From CovidDeaths D
Join CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null
--order by 1,2


select * from percentpopulationvaccinated






