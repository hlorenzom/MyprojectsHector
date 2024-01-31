Select *
from dbo.CovidDeaths
order by 3,4

Select *
from dbo.CovidVaccinations
order by 3,4

-- Select Data that we are going to be using


Select  Location, date, total_cases, new_cases, total_deaths,population
from dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
--  Show likelihood of dying if you contract covid in your country
Select  Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where location like '%Rico%'
order by 1,2
-- Alter table CovidDeaths ALTER COLUMN  [total_deaths] [FLOAT]

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select  Location, date, population, total_cases,  (total_cases/population)*100 as PercentagePopulationInfected
from dbo.CovidDeaths
where location like '%Rico%'
order by 1,2

-- Looking at countries with highest infection rate compared to Population 

Select  Location, population, Max(total_cases) as HighestInfectionCount,  (max(total_cases)/population)*100 as PercentagePopulationInfected
from dbo.CovidDeaths
Group by Location, population
order by PercentagePopulationInfected decs

Select  Location, population, Max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentagePopulationInfected
from dbo.CovidDeaths
Group by Location, population
order by PercentagePopulationInfected desc

-- Showing countries with highest death count per population

Select  Location, max(cast(total_deaths as int)) as TotalDeathCount 
from dbo.CovidDeaths
Group by Location
order by TotalDeathCount desc

--  removing continent and world
Select  Location, max(cast(total_deaths as int)) as TotalDeathCount 
from dbo.CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- let break this down by continent
Select  continent, max(cast(total_deaths as int)) as TotalDeathCount 
from dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

Select  Location, max(cast(total_deaths as int)) as TotalDeathCount 
from dbo.CovidDeaths
where continent is  null
Group by Location
order by TotalDeathCount desc

-- Showing the continent with the highest death count per population.

Select  continent, max(cast(total_deaths as int)) as TotalDeathCount 
from dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(new_deaths)as total_death,sum(new_deaths)/sum(New_Cases)*100 as DeathPercentage
from dbo.CovidDeaths
where new_cases is not null
group by date
order by 1,2

--Global death percentage

Select SUM(new_cases) as total_cases, SUM(new_deaths)as total_death,sum(new_deaths)/sum(New_Cases)*100 as DeathPercentage
from dbo.CovidDeaths

--  Death percentag by countries

Select  Location,  max(total_cases) as TotalCount, max(total_deaths) as TotalDeathCount, max(total_deaths)/max(total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is  not null
Group by Location
order by DeathPercentage desc 

Select * 
From dbo.CovidVaccinations


Select * 
From dbo.CovidVaccinations vac
join dbo.CovidDeaths dea
on  dea.location = vac.location
and dea.date = vac.date

-- Looking at Total Population vs Vaccionations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From dbo.CovidVaccinations vac
join dbo.CovidDeaths dea
on  dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2, 3


-- Looking at Total Population vs Vaccionations  rolling total

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(float,vac.new_vaccinations)) over (partition by dea.location)
From dbo.CovidVaccinations vac
join dbo.CovidDeaths dea
on  dea.location = vac.location
and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null
order by 1,2, 3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulateVaccinated
From dbo.CovidVaccinations vac
join dbo.CovidDeaths dea
on  dea.location = vac.location
and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null
order by 1,2, 3

--  percentage of cum vacinated using CTE
With PopvsVac (continent, location, date, population, new_vaccinations,CumulateVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulateVaccinated
From dbo.CovidVaccinations vac
join dbo.CovidDeaths dea
on  dea.location = vac.location
and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null
)
Select *, (CumulateVaccinated/ population) *100 as PercentageVacinated
from PopvsVac

--  percentage of cum vacinated using Temp Table

Drop Table if exists #PercentagePopulationVAccinated
Create table #PercentagePopulationVAccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulateVaccinated numeric
)

Insert into #PercentagePopulationVAccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulateVaccinated
From dbo.CovidVaccinations vac
join dbo.CovidDeaths dea
on  dea.location = vac.location
and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null

Select *, (CumulateVaccinated/ population) *100 as PercentageVacinated
from #PercentagePopulationVAccinated

--  Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulateVaccinated
From dbo.CovidVaccinations vac
join dbo.CovidDeaths dea
on  dea.location = vac.location
and dea.date = vac.date
where vac.new_vaccinations is not null and dea.continent is not null


Select *
From PercentPopulationVaccinated

1:14:00