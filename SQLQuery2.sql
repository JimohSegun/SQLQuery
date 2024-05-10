select *
from PROJECT..covidDeath
where continent is not null

select *
from PROJECT..covidVaccination

select location, date, total_cases, total_deaths, population
from PROJECT..covidDeath
order by 1, 2


--Getting death percentage

select location, date, total_cases, total_deaths, (CONVERT(int, total_deaths ) / CONVERT(int, total_cases)) *100 as DeathPercentage
from PROJECT..covidDeath
where location like '%nigeria%' and continent is not null
order by 1, 2



--Getting percentage of population infected

select location, date, population , total_cases, (total_cases / population) * 100 as PercentagePoulationInfected
from PROJECT..covidDeath
where location like '%nigeria%'
order by 1, 2



--Getting hightest percentage population infected 

select location, population, MAX(total_cases) as HightestInfection , Max(total_cases / population) * 100 as HightestPectentagePoulationInfected
from PROJECT..covidDeath
group by location, population
order by HighestPectentagePoulationInfected desc



--Getting hightest total death by location

select location, MAX(CONVERT(int, total_deaths)) as TotalDeathCount
from PROJECT..covidDeath
where continent is not null
group by location
order by TotalDeathCount desc



--Getting hightest total death  by continent 

Select continent, MAX(CONVERT(int, total_deaths)) as TotalDeathCount
From PROJECT..covidDeath
Where continent is not null
Group by continent
Order by continent desc



--Getting global Cases of infection

select date, SUM(CONVERT(int, new_cases)) as total_cases,SUM( CONVERT(int,new_deaths)) as total_death, SUM( CONVERT(int,new_deaths)) /NULLIF( SUM(CONVERT(int, new_cases)) , 0) * 100 as DeathPercentage
from PROJECT..covidDeath
Where continent is not null
Group by date, CONVERT(int, total_cases),CONVERT(int,total_deaths)
Order by 1, 2



--Getting world Cases of infection

select SUM(CONVERT(int, new_cases)) as total_cases,SUM( CONVERT(int,new_deaths)) as total_death, SUM( CONVERT(int,new_deaths)) /NULLIF( SUM(CONVERT(int, new_cases)) , 0) * 100 as DeathPercentage
from PROJECT..covidDeath
where continent is not null
Order by 1, 2



--Getting total number of people vaccinated

select Death.continent, Death.location,Death.date,Death.population,Vacc.new_vaccinations,
Sum(Convert(float,Vacc.new_vaccinations)) OVER (PARTITION BY Death.location Order by Death.location, Death.date) as RollingPeopleVaccinated
from PROJECT..covidDeath AS Death
join PROJECT..covidVaccination AS Vacc
  ON Death.location = Vacc.location
  and Death.date = Vacc.date
Where Death.continent is not null
Order by 1 , 2


--Getting number of vaccinated population by location

WITH PopvsVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as (select Death.continent, Death.location,Death.date,Death.population ,Vacc.new_vaccinations,
Sum(Convert(float,Vacc.new_vaccinations)) OVER (PARTITION BY Death.location Order by Death.location, Death.date) as RollingPeopleVaccinated
from PROJECT..covidDeath AS Death
join PROJECT..covidVaccination AS Vacc
  ON Death.location = Vacc.location
  and Death.date = Vacc.date
Where Death.continent is not null)
Select * , (RollingPeopleVaccinated / population) * 100 as RollingPopulationVaccinated
from PopvsVacc



--Create view to store data for visualization

Create View hightestDeathByContinent AS 
Select continent, MAX(CONVERT(int, total_deaths)) as TotalDeathCount
From PROJECT..covidDeath
Where continent is not null
Group by continent

Create view riskAware AS
select location, date, total_cases, total_deaths, (CONVERT(int, total_deaths ) / CONVERT(int, total_cases)) *100 as DeathPercentage
from PROJECT..covidDeath
where location like '%nigeria%' and continent is not null

Create view popuStats AS
select location, date, population , total_cases, (total_cases / population) * 100 as PercentagePoulationInfected
from PROJECT..covidDeath
where location like '%nigeria%'

Create view hightestCovidRate AS
select location, population, MAX(total_cases) as HightestInfection , Max(total_cases / population) * 100 as HighestPectentagePoulationInfected
from PROJECT..covidDeath
group by location, population

Create view countryHighestDeath AS
select location, MAX(CONVERT(int, total_deaths)) as TotalDeathCount
from PROJECT..covidDeath
where continent is not null
group by location

Create view continent AS
Select continent, MAX(CONVERT(int, total_deaths)) as TotalDeathCount
From PROJECT..covidDeath
Where continent is not null
Group by continent

Create view globalCases AS
select date, SUM(CONVERT(int, new_cases)) as total_cases,SUM( CONVERT(int,new_deaths)) as total_death, SUM( CONVERT(int,new_deaths)) /NULLIF( SUM(CONVERT(int, new_cases)) , 0) * 100 as DeathPercentage
from PROJECT..covidDeath
Where continent is not null
Group by date, CONVERT(int, total_cases),CONVERT(int,total_deaths)

Create view worldCases AS
select SUM(CONVERT(int, new_cases)) as total_cases,SUM( CONVERT(int,new_deaths)) as total_death, SUM( CONVERT(int,new_deaths)) /NULLIF( SUM(CONVERT(int, new_cases)) , 0) * 100 as DeathPercentage
from PROJECT..covidDeath
where continent is not null

