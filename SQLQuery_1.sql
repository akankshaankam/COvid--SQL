select * from portfolioproject..Coviddeaths
where continent is not null
order by 3,4

--select * from portfolioproject..CovidVaccinations
--order by 3,4

--Select data
select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..Coviddeaths
order by 1,2

--Looking at total_cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, cast(total_deaths *100.0 / total_cases as decimal(10,5)
) as death_percentage
from portfolioproject..Coviddeaths
where location like '%Asia%'
order by 1,2;

--looking at total_cases vs population
--What % of population got covid in specified country
select location, date, Population, total_cases, cast(total_cases *100.0 / population as decimal(10,5)
) as death_percentage
from portfolioproject..Coviddeaths
--where location like '%Asia%'
order by 1,2;


--looking at countries with highest infected rate compared to population
select location, Population, MAX(total_cases) as highinfectcount, MAX(CAST(total_cases*100.0 / population as decimal(10,5)))
as percent0fpop_infected
from portfolioproject..Coviddeaths
where continent is not null
--where location like '%Asia%'
group by location, population
order by percent0fpop_infected DESC


-- How many people have actually died in each country
select location, MAX(total_deaths) as DeathCount
, MAX(CAST(total_deaths * 100.0/population as decimal(10,4)))
as MaxDeathPercent
from portfolioproject..Coviddeaths
where continent is not null
group by location, population
order by DeathCount DESC

--showing continents with highest deathcount
select continent, MAX(total_deaths) as DeathCount
from portfolioproject..Coviddeaths
where continent is not null
group by continent
order by DeathCount DESC

--finding death percentage each day

select date, SUM(new_cases) as total_newcases, sum(cast(new_deaths as int)) as total_newdeaths, 
CASE 
when sum(new_cases) > 0 THEN
    sum(cast(new_deaths as float))/sum((new_cases))*100.0 
ELSE
    0
end as death_percentage
from portfolioproject..Coviddeaths
where continent is not null
group by date 
order by date


--- by year
select YEAR(date) as year, SUM(new_cases) as total_newcases, sum(cast(new_deaths as int)) as total_newdeaths, 
CASE 
when sum(new_cases) > 0 THEN
    sum(cast(new_deaths as float))/sum((new_cases))*100.0 
ELSE
    0
end as death_percentage
from portfolioproject..Coviddeaths
where continent is not null
group by YEAR(date) 
order by year



With PopvsVac (Continent, location,date, population,New_Vaccinations, rollpeoplevaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date)
as rollpeoplevaccinated
--, (rollpeoplevaccinated/population)*100
from portfolioproject..Coviddeaths dea join portfolioproject..Covidvaccinations vac
on dea.location = vac.LOCATION
and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3
)
select * from PopvsVac


--Temp table

CREATE TABLE #PercentPopulationVaccinated
( 
    Continent nvarchar(255), location varchar(255),Date datetime,
    population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date)
as rollpeoplevaccinated
--, (rollpeoplevaccinated/population)*100
from portfolioproject..Coviddeaths dea join portfolioproject..Covidvaccinations vac
on dea.location = vac.LOCATION
and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated;


--Views

CREATE VIEW PercentPopulationVaccinated as
SELECT 
    dea.continent,  
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) rollpeoplevaccinated
FROM portfolioproject..Coviddeaths dea 
JOIN portfolioproject..Covidvaccinations vac
ON dea.location = vac.LOCATION
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

select * from PercentPopulationVaccinated

