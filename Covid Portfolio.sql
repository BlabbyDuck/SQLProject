--SELECT *
--FROM master ..[CovidDeath]
--order by 3,4

--SELECT *
--FROM master ..[ CovidVaccinations]
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM master ..[CovidDeaths]
ORDER BY 1,2

-- Looking at total cases vs total deaths 
SELECT Location, date, total_cases, total_deaths, (CAST((total_deaths/ total_cases) AS DECIMAL(5,4)) * 100) AS Percentage_of_Death
FROM master ..[CovidDeaths]
WHERE location like '%Sing%'
ORDER BY 5 DESC
-- Shows the likelihood of dying if you contracted covid in Singapore. In general, the percentage remains relatively low and consistent throughout.
--Peak of the deaths hovers between 2020-04 to 2020-03

-- Looking at total cases vs total deaths 
SELECT Location, date, population, total_cases, (CAST((total_cases/ population) AS DECIMAL(30,20)) * 100) AS Population_infected
FROM master ..[CovidDeaths]
WHERE location like '%Sing%'
ORDER BY 1,2 
-- the number of population infected is relatively small at the beginning, but slowly increases to approximatly 1% towards the end of 2021 - 04

-- Looking at Countries with Highest infection rate compared to Population
SELECT Location, population, MAX(total_cases) AS Highest_Inf_count, MAX((total_cases/ population) * 100) AS Max_Cases
FROM master ..[CovidDeaths]
GROUP BY Location, Population
--WHERE location like '%Sing%'
ORDER BY Max_Cases DESC

-- Looking at Countries with Highest infection rate compared to Population
SELECT Location, population, MAX(total_cases) AS Highest_Inf_count, MAX((total_cases/ population) * 100) AS Max_Cases
FROM master ..[CovidDeaths]
GROUP BY Location, Population
--WHERE location like '%Sing%'
ORDER BY Max_Cases DESC


-- Showing Countries with the highest death count per population MAX((total_deaths/population) * 100) AS Percentage_death
SELECT Location, MAX(total_Deaths) as Total_Death_Count
FROM master ..[CovidDeaths]
WHERE continent is null
GROUP BY Location
ORDER BY Total_Death_Count DESC

-- Showing continent with the highest death count per population
SELECT continent, MAX(total_Deaths) as Total_Death_Count
FROM master ..[CovidDeaths]
WHERE continent is not NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- Global Number
SELECT date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/ SUM(new_cases) * 100 as DeathPercentage
From master ..[CovidDeaths]
WHERE continent is not NULL
GROUP BY date
order by 1,2

-- Looing at total population vs Vaccinations. We add the vaccination daily to compute total _vacc col
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated

From master ..[CovidDeaths] AS dea
JOIN  master ..[CovidVaccinations] AS vac 
    ON dea.location = vac.[location] and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

--Using CTE to calculated population vaccinated
WITH PopvsVac (continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
From master ..[CovidDeaths] AS dea
JOIN  master ..[CovidVaccinations] AS vac 
    ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac

-- Temp TABLE
DROP TABLE if EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population NUMERIC,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
From master ..[CovidDeaths] AS dea
JOIN  master ..[CovidVaccinations] AS vac 
    ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated

--Create a view for data Visualisation
CREATE View PercentPopulationVaccinated as 
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
From master ..[CovidDeaths] AS dea
JOIN  master ..[CovidVaccinations] AS vac 
    ON dea.location = vac.location 
    and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3