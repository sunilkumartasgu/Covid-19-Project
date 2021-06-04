USE [Portfolio project]
GO

SELECT *
  FROM [dbo].[Covid Deaths]
  where continent is not null
order by 3,4


SELECT location, date,total_cases,new_cases,total_deaths,population
  FROM [dbo].[Covid Deaths]
  order by 1,2

  -- Total cases vs Total deaths in India

  SELECT location, date,total_cases,total_deaths,((total_deaths/total_cases)*100)as Death_percentage
  FROM [dbo].[Covid Deaths]
  WHERE location like 'India'
  order by 1,2

  --Total cases vs Population

  SELECT location, date,total_cases,Population,((total_cases/Population)*100)as Infection_percentage
  FROM [dbo].[Covid Deaths]
  WHERE location like 'India'
  order by 1,2

--Countries with higher infection rate compared to population

  SELECT location,MAX(total_cases) AS HighestInfectionCount,Population,((MAX(total_cases)/Population)*100)as highestInfection_percentage
  FROM [dbo].[Covid Deaths]
  GROUP BY location, population
  ORDER BY highestInfection_percentage DESC


  --Countries with highest death counts per Population

 
   SELECT location,MAX(cast(total_deaths as int)) AS TotalDeathsCount
  FROM [dbo].[Covid Deaths]
  where continent is not null
  GROUP BY location
  ORDER BY TotalDeathsCount DESC


  --Based on Continent

  --Continent with highest death counts per Population

SELECT location,MAX(cast(total_deaths as int)) AS TotalDeathsCount
  FROM [dbo].[Covid Deaths]
  where continent is null
  GROUP BY location
  ORDER BY TotalDeathsCount DESC


  --Global numbers

   SELECT date,SUM(new_cases)as Total_cases,SUM(CAST(new_deaths as int)) as Total_deaths,(SUM(CAST(new_deaths as int))/(SUM(new_cases)))*100 as Death_percentage
  FROM [dbo].[Covid Deaths]
    where continent is not null
	GROUP BY date
  order by 1,2

  --Global numbers total number

   SELECT SUM(new_cases)as Total_cases,SUM(CAST(new_deaths as int)) as Total_deaths,(SUM(CAST(new_deaths as int))/(SUM(new_cases)))*100 as Death_percentage
  FROM [dbo].[Covid Deaths]
    where continent is not null
  order by 1,2

  --Upto JUNE-2021 
  --Totalcases:17119395
  --Totaldeaths:356577
  --DeathPercentage:2.0825

  

  --Total Population vs vaccination

  SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER(partition by dea.location ORDER BY dea.location,dea.date)as RollingPeopleVaccinated
    FROM [dbo].[Covid Deaths] dea
    JOIN [dbo].[Covid Vaccinations] vac
	ON dea.location= vac.location
	AND dea.date= vac.date
	WHERE dea.continent is not null
	ORDER BY 2,3


	--USE CTE
WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER(partition by dea.location ORDER BY dea.location,dea.date)as RollingPeopleVaccinated
    FROM [dbo].[Covid Deaths] dea
    JOIN [dbo].[Covid Vaccinations] vac
	ON dea.location= vac.location
	AND dea.date= vac.date
	WHERE dea.continent is not null
	)

SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Temp Table

drop table if exists #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER(partition by dea.location ORDER BY dea.location,dea.date)as RollingPeopleVaccinated
    FROM [dbo].[Covid Deaths] dea
    JOIN [dbo].[Covid Vaccinations] vac
	ON dea.location= vac.location
	AND dea.date= vac.date
	--WHERE dea.continent is not null

SELECT *,(RollingPeopleVaccinated/population)*100 as PerRollPplVac
FROM #Percent_Population_Vaccinated


--Creating view to store data for later visualisations

CREATE VIEW Percent_Population_Vaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER(partition by dea.location ORDER BY dea.location,dea.date)as RollingPeopleVaccinated
    FROM [dbo].[Covid Deaths] dea
    JOIN [dbo].[Covid Vaccinations] vac
	ON dea.location= vac.location
	AND dea.date= vac.date
	WHERE dea.continent is not null


--Retriving data from newly created table
SELECT *
FROM Percent_Population_Vaccinated