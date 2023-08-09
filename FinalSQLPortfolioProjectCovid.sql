--An Analysis of Publically Available Data Concerning Covid19

--Looking at Total Cases vs Population
--Shows what percentage of the population of the US got covid
SELECT Location, Date, Total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location IN ('United States','US') and continent is not NULL
order by 1,2 DESC

--Looking at Total Death Count vs Continent
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL and Location not like '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population 
--using a like statement to clean the data
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL and Location not like '%income%'
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Looking at Total Cases vs Population
--Shows what percentage of the population of each continent got covid
SELECT continent, Date, Total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
order by 1,2 DESC

--Shows which continents had the highest infection rate of covid
SELECT continent, Population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Population,continent
ORDER BY PercentPopulationInfected DESC

--Showing Continents with Highest Death Count per Capita
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Using aggregate functions to calculate total percentage of global population killed by covid
Create View TotalGlobalDeaths as
SELECT SUM(new_cases) as Total_Cases,SUM(new_deaths) as Total_Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as
DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and new_cases <> 0

--Using aggregate functions to calculate the percentage of population killed by covid for a particular day
Create View DeathPercentage as 
SELECT date,SUM(new_cases) as Total_Cases,SUM(new_deaths) as Total_Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as
DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and new_cases <> 0
GROUP BY Date

--Using a partition to create a rolling count of total people vaccinated for each day
Create View RollingPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

--Looking into the effectiveness of the vaccine in reducing deaths
DROP Table if exists #PercentTotalDeaths
Create Table #PercentTotalDeaths
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Total_Deaths numeric,
total_vaccinations nvarchar(255)
)
Insert Into #PercentTotalDeaths
Select dea.continent, dea.location, dea.date, dea.population, dea.total_deaths, vac.total_vaccinations
From PortfolioProject..CovidDeaths dea
FULL OUTER JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, Total_Deaths/Population as DeathsPerCapita, total_vaccinations/Population as VaccinationsPerCapita
From #PercentTotalDeaths


--Use CTE to compare total vaccinations per hundred people with excess mortality per million people
Create View PopvsVac as
With PopvsVac (Continent,location,date,total_vaccinations_per_hundred, people_vaccinated_per_hundred,people_fully_vaccinated_per_hundred, excess_mortality_cumulative_per_million)
as
(
Select dea.continent, dea.location, dea.date, vac.total_vaccinations_per_hundred, vac.people_vaccinated_per_hundred, vac.people_fully_vaccinated_per_hundred, vac.excess_mortality_cumulative_per_million
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
where dea.continent is not null
)
select distinct continent, location, date, total_vaccinations_per_hundred,excess_mortality_cumulative_per_million
From PopvsVac