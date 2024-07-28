/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..covidDeath
WHERE continent is not NULL


-- Total Cases vs Total Deaths........................................................................................................................
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, 
       date, 
	   total_cases, 
	   total_deaths,
	   (CONVERT(float, total_deaths) / CONVERT(float, total_cases))*100  as DeathPercentage
FROM 
       PortfolioProject..covidDeath
WHERE continent is not NULL 
      AND Location LIKE '%Nigeria%'
Order By 1, 2



-- Total Cases vs Population..............................................................................................................................
-- Shows what percentage of population infected with Covid
SELECT 
       Location, 
	   date,
	   population,
	   total_cases, 
	   (total_cases / population) * 100 AS PercentPopulationInfected
FROM 
       PortfolioProject..covidDeath
WHERE Location LIKE '%Nigeria%'
Order By 1, 2



-- Countries with Highest Infection Rate compared to Population..............................................................................................
SELECT 
      Location, 
      population, 
	  MAX(total_cases) as HightestInfection, 
	  MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM  PortfolioProject..covidDeath
WHERE continent is not NULL
GROUP BY location, population
Order By PercentPopulationInfected desc,  HightestInfection desc 


-- Countries with Highest Death Count per Population.................................................................................................
SELECT 
       Location, 
	   MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeath
WHERE continent IS not NULL
GROUP BY location
ORDER BY TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT.....................................................................................................

-- Showing contintents with the highest death count per population
SELECT 
       location, 
	   MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM   PortfolioProject..covidDeath
WHERE  continent IS NULL
GROUP BY  location
ORDER BY TotalDeathCount desc



--Showing CONTINET with The highest Death Count Per Population..............................................................

SELECT 
       continent, 
	   MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM   PortfolioProject..covidDeath
WHERE  continent IS not NULL
GROUP BY  continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS...............................................................................................
SELECT 
       SUM(new_cases) total_cases , 
	   SUM( CONVERT(int, new_deaths)) as total_deaths, 
	   (SUM(new_deaths)/SUM(new_cases))* 100 as DeathPercentage
FROM PortfolioProject..covidDeath
WHERE continent IS not NULL 
ORDER BY 1, 2



-- Total Population vs Vaccinations.................................................................................................................
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortfolioProject..covidDeath dea 
JOIN PortfolioProject..covidVacination vac
  ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 1, 2, 3




-- Using CTE to perform Calculation on Partition By in previous query........................................................................
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
  SELECT 
         dea.continent, 
		 dea.location, 
		 dea.date, 
		 dea.population, 
		 vac.new_vaccinations, 
         SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
         PortfolioProject..covidDeath dea 
JOIN    
       PortfolioProject..covidVacination vac
ON 
       dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated / population) *100 VaccinatedPopulation
FROM  PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query...................................................................
DROP Table if exists #PercentagePopluationVaccination

CREATE TABLE #PercentagePopluationVaccination(
continent nvarchar(522),
location nvarchar(522),
date datetime,
population numeric,
new_vaccinations  numeric, 
RollingPeopleVaccinated  numeric
)

INSERT INTO #PercentagePopluationVaccination
 SELECT 
         dea.continent, 
		 dea.location, 
		 dea.date, 
		 dea.population, 
		 vac.new_vaccinations, 
         SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
         PortfolioProject..covidDeath dea 
JOIN    
       PortfolioProject..covidVacination vac
ON 
       dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *,(RollingPeopleVaccinated /population) *100 AS VaccinatedPopulation
FROM #PercentagePopluationVaccination



-- Creating View to store data for later visualizations............................................................................................

Create View PercentPopulationVaccinated AS
 SELECT 
         dea.continent, 
		 dea.location, 
		 dea.date, 
		 dea.population, 
		 vac.new_vaccinations, 
         SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
         PortfolioProject..covidDeath dea 
JOIN    
       PortfolioProject..covidVacination vac
ON 
       dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated


