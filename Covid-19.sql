SELECT *
FROM [Portfolio Project].dbo.CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project].dbo.CovidVaccination
--ORDER BY 3,4

--Select the data 
SELECT location,date,total_cases,new_cases,total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by location,date

--Total cases vs Total Deaths:
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
where location = 'India'
order by location, date

--Total Cases vs the Population:
--Shows the percentage that got Covid in India

SELECT location, date, total_cases, population, (total_cases/population)*100 as PopulationInfectedPercentage
FROM [Portfolio Project].dbo.CovidDeaths
--where location = 'India'
where continent is not null
order by location, date

--Countries with highest infection rate:

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PopulationInfectedPercentage
FROM [Portfolio Project].dbo.CovidDeaths 
where continent is not null
group by location, population
order by PopulationInfectedPercentage DESC

--Countries with highest death count per population

SELECT location,MAX(cast(total_deaths as int))as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--By Continent:
SELECT location, MAX(cast(total_deaths as int))as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc


--Global numbers

SELECT  date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
where continent is not null
Group by date
order by 1, 2


--Covid Vaccination Table


--Joining both the Tables 

SELECT * 
FROM [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Total Population vs Vaccinations
--Useing CTE
With PopvsVac (Continent,location, date, polulation,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations))  OVER (Partition BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

FROM [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
