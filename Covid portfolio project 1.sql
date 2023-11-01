select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--selecting only the code we will be working on--

select location,date ,total_cases,total_deaths ,[population],new_cases
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths--
--shows likelihhod of dying if you contract covid in your country--

select location,date ,total_cases,total_deaths, 
       (convert(float,total_deaths)/nullif(convert(float,total_cases),0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location = 'India'
order by 1,2  

--looking at total cases vs population--
--shows the percentage of population got covid in your country--

select location,date ,total_cases , [population]
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking for percentage of population infected by covid 

select location , date , population, total_cases ,
        (convert(float,total_cases)/population)*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location='India'
order by 1, 2 

--looking at countries with their highest number of infected population and its percentage--

select location , population,MAX(total_cases) as HighestInfectionCount ,
     MAX ((convert(float,total_cases)/population)*100) as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
--where location='India'
where continent is not null
GROUP BY location ,population
order by InfectedPopulationPercentage DESC

--looking for countries having highest total death counts--

 select location ,MAX(cast(total_deaths as int)) as highestdeathcounts 
 from PortfolioProject..CovidDeaths
 where continent is not null
--where location='India'
GROUP BY location 
order by highestdeathcounts DESC

--lets break this by continents--

select continent ,MAX(cast(total_deaths as int)) as highestdeathcounts 
 from PortfolioProject..CovidDeaths
 where continent is not null
--where location='India'
GROUP BY continent
order by highestdeathcounts DESC

--GLOBAL NUMBERS--

select
sum(cast(new_cases as int)) as Totalcases , sum(cast(new_deaths as int)) as Totaldeaths,
sum((cast(new_deaths as int)/nullif(convert(int,new_cases),0))*100) as Deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location='India'
--group by date
order by 1, 2 


--looking at total population vs vaccination--

select  dea.continent,dea.location , dea.date,dea.population,vac.new_vaccinations,
Sum(convert(float,new_vaccinations))over (partition by dea.location order by dea.location,dea.date)
as RollingpeopleVaccinated 
--(RollingpeopleVaccinated/dea.population)*100 as RollingvaccinationPercent
from PortfolioProject..CovidDeaths   dea
Join PortfolioProject..CovidVaccinations  vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3;

--adding rollingpeople vaccinated column to a temporary table--
--use CTE--

with PopvsVac(Continent,Location,Date,Population,New_vaccinations,RollingpeopleVaccinated)
as
(
select  dea.continent,dea.location , dea.date,dea.population,vac.new_vaccinations,
Sum(convert(float,new_vaccinations))over (partition by dea.location order by dea.location,dea.date)
as RollingpeopleVaccinated 
--(RollingpeopleVaccinated/dea.population)*100 as RollingvaccinationPercent
from PortfolioProject..CovidDeaths   dea
Join PortfolioProject..CovidVaccinations  vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3
)
select*
from PopvsVac

--TEMP TABLE--
drop table #PercentpopulationVaccinated
create table #PercentpopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric ,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)
insert into  #PercentpopulationVaccinated 
select  dea.continent,dea.location , dea.date,dea.population,vac.new_vaccinations,
Sum(convert(float,new_vaccinations))over (partition by dea.location order by dea.location,dea.date)
as RollingpeopleVaccinated 
--(RollingpeopleVaccinated/dea.population)*100 as RollingvaccinationPercent
from PortfolioProject..CovidDeaths   dea
Join PortfolioProject..CovidVaccinations  vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3

select *
from  #PercentpopulationVaccinated

--creating view for store data for later visualization--

create view PercentpopulationVaccinated as
select  dea.continent,dea.location , dea.date,dea.population,vac.new_vaccinations,
Sum(convert(float,new_vaccinations))over (partition by dea.location order by dea.location,dea.date)
as RollingpeopleVaccinated 
--(RollingpeopleVaccinated/dea.population)*100 as RollingvaccinationPercent
from PortfolioProject..CovidDeaths   dea
Join PortfolioProject..CovidVaccinations  vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3

select*
from PercentpopulationVaccinated 