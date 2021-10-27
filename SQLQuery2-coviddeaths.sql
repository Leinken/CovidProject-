----Create database CovidProject
----go
----use CovidProject

select * from CovidProject..CovidDeaths
order by 3,4


--select * from CovidProject..CovidVaccinations
--order by 3,4

----Select Data that we are going to be using

--Select location, date, total_cases, new_cases, total_deaths, population
--from CovidDeaths 
--order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likehood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage --find the percebtage of people who got the virus and died from it
from CovidDeaths 
where location like '%states%'
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population has gotten covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected --find the percebtage of people who got the virus and died from it
from CovidDeaths 
where location like '%states%'
order by 1,2 


--Looking at Countries with the Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected --find the percebtage of people who got the virus and died from it
from CovidDeaths 
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc -- the desc gets the highest number first to low.


--(Sad data1)Showing Countries with the Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths 
--where location like '%states%'
Group by location
order by TotalDeathCount desc 


select * from CovidProject..CovidDeaths   --filtering data by limiting nulls in continet. Avoids appearing of continets in location column
order by 3,4

--(Sad data 2)Showing Countries with the Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount --BY Country
from CovidDeaths  --
--where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc 



--LET'S BREAK THINGS DOWN BY CONTINENT


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount --
from CovidDeaths 
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc 

-- Showing continets with the Highest death count per Population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount --
from CovidDeaths 
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc 


--More accurate death data by continent. 

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount --
from CovidDeaths 
--where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc 


--GLOBAL NUMBER
--Looking at sum of the new cases in general by date

Select date, SUM(new_cases) -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths 
--where location like '%states%'
where continent is not null
group by date 
order by 1,2


--New cases data is in float format, while new deaths data is in nvarchar format  
--Across the globe

Select date, SUM(new_cases) as Totalcases, SUM(cast(new_deaths as int)) as Totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as DeathPercentage from CovidDeaths --Across the globe
--where location like '%states%'
where continent is not null
group by date 
order by 1,2


-- Global Total Cases, TotalDeaths, Deathpercentage


Select SUM(new_cases) as Totalcases, SUM(cast(new_deaths as int)) as Totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as DeathPercentage from CovidDeaths --Across the globe
--where location like '%states%'
where continent is not null
--group by date 
order by 1,2


--Looking at Total Population VS Vaccinations. Trying to get the total number of people vaccinated in the world.
-- new vaccination per day


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations from CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


---- new vaccination per day
--we want to check the new vaccination in desc order per region. 
--Cast function converts an expression from one datatype to another.
--Order by 2,3 - it sorts the result by the second and third column
--Group by - is used to apply aggregate function for each group. also used to group rows that have the same values. 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location) from CovidDeaths dea --we want to partition by location for instance Canada.
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Another way to convert data type. Insteasd of Cast we use Convert. 
--Rolling People Vaccinated per location. We get the sum of vaccinated people by location. 
--At the bottom of each Country we see the Max number of vaccinated people.
--For instance for Albania location the Max number is 1247999


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea --we want to partition by location for instance Canada.
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--TO KNOW HOW MANY PEOPLE IN  A COUNTRY ARE VACCINATED
--We use the MAX number devided by the Country population.
--We can not use a column we just created for caluclation. we will get an error. We ned to create a CTE or a TEMP Table


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
(RollingPeopleVaccinated/population)*100   --WE can not use a column we just created for caluclation. we will get an error. 
from CovidDeaths dea                       --we want to partition by location for instance Canada.
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USE CTE
--Number of columns in the CTE must match the number of columns in the select statement

With PopvsVac (Continet, location, date, population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100   --WE can not use a column we just created for caluclation. we will get an error. 
from CovidDeaths dea                         --we want to partition by location for instance Canada.
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--IF we want to get the MAX, we may need to get rid of date since it will throw off our results


With PopvsVac (Continet, location, population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100   --WE can not use a column we just created for caluclation. we will get an error. 
from CovidDeaths dea                         --we want to partition by location for instance Canada.
Join CovidVaccinations vac
	On dea.location = vac.location
	Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--*Need to be Fixed*
--TEMP TABLE 

Drop Table if exists #PercentPopulationVaccinated

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100   --WE can not use a column we just created for caluclation. we will get an error. 
from CovidDeaths dea                         --we want to partition by location for instance Canada.
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data data for later visualiztion

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100   
from CovidDeaths dea                         
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--Order by 2,3

SElect * from #PercentPopulationVaccinated








