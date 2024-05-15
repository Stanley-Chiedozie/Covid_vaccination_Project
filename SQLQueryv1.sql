--SELECT *
--FROM vaccinatn

--SELECT *
--FROM covidDeat

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covidDeat
Order by 1,2

--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covidDeat
WHERE location like '%NIGERIA%' and continent is not null
Order by 1,2

--looking at total cases vs population
--showing what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS death_percentage
FROM covidDeat
Order by 1,2

--looking at countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS infected_percentage
FROM covidDeat
Group by location, population
Order by infected_percentage desc

--showing the countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM covidDeat
WHERE continent is not null
Group by location
Order by total_death_count desc

--lets break things down by continent

--showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM covidDeat
WHERE continent is not null
Group by continent
Order by total_death_count desc

--global numbers

SELECT date, SUM(new_cases), SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM covidDeat
--WHERE location like '%NIGERIA%'
WHERE continent is not null
Group by date
Order by 1,2


-- looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER(Partition by dea.location Order by dea.location, dea.date) AS rolling_people_vaccinated
FROM covidDeat AS dea
JOIN vaccinatn AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not  null
Order by 2,3


-- use cte

With populationvsvaccinated (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER(Partition by dea.location Order by dea.location, dea.date) AS rolling_people_vaccinated
FROM covidDeat AS dea
JOIN vaccinatn AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not  null
--Order by 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM populationvsvaccinated


--Temp Table
Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER(Partition by dea.location Order by dea.location, dea.date) AS rolling_people_vaccinated
FROM covidDeat AS dea
JOIN vaccinatn AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not  null
--Order by 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentagePopulationVaccinated


--creating view to store data for later visualization

Create view PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER(Partition by dea.location Order by dea.location, dea.date) AS rolling_people_vaccinated
FROM covidDeat AS dea
JOIN vaccinatn AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not  null
--Order by 2,3

SELECT *
FROM PercentagePopulationVaccinated