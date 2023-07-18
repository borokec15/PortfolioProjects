Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

--Selecting data I need

Select location, date, total_cases, new_cases, total_deaths, population  
From PortfolioProject..CovidDeaths
Order by 1,2

-- Total Cases vs Total Deaths and DeathPercentage in North Macedonia 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%North M%'
and continent is not null
Order by 1,2

--Total Cases vs Population in North Macedonia (what percentage of population has gotten covid)
Select location, date, total_cases, population, (total_cases/population) as CovidDensity
From PortfolioProject..CovidDeaths
Where location like '%North M%'
and continent is not null
Order by 1,2

--Countires with highest infection rate compared to population

Select location, population,  Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 As 
PercentofPopInfected
From PortfolioProject..CovidDeaths
--Where location like '%North M%'
Group by location, population
Order by PercentofPopInfected desc

--Breaking things down by continent
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
Order by TotalDeathCount desc


--Countries with the highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location 
Order by TotalDeathCount desc

--Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
Order by TotalDeathCount desc

--Global numbers

Select date, Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercenatge
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

Select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercenatge
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2
---------CovidDeaths+CovidVaccinations

--Total Population vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated,
--(PeopleVaccinated/population)*100 -- can't do this without CTE or Temp table
From  PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

With PopvsVac (Continent, Location, Date, Population,new_vaccinations, PeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (PeopleVaccinated/Population)*100 as PeopleVaccinatedPercentage
From PopvsVac

----Temp table
--Drop table if exists #PercentPopulationVaccinated
--Create Table #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--new_vaccinations numeric,
--PeopleVaccinatedPercentage numeric
--)
--Insert into #PercentPopulationVaccinated
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null

--Select *, (PeopleVaccinated/Population)*100
--From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as  
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated