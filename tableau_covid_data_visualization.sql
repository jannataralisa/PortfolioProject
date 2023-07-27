--Show total death in global wise
--show death in bangladesh
--show total vaccineated percentage in continent


-- 1 GLOBAL NUMBERS of death and new cases

	Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	FROM [dbo].[CovidDeaths]
	where continent is not null 
	order by 1,2

--2 Continent based total death
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 4 Continent based average new vaccination
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

	SELECT d.continent, d.location,d.population,d.date, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY d.location order by d.date) as Rollingpeoplevaccinated
	FROM [dbo].[CovidDeaths] as d
	Join [dbo].[CovidVaccinations] as vac
		ON d.location=vac.location
		and d.date=vac.date 
	where d.continent is not null and vac.new_vaccinations is not null
	order by 2,3 

-- 5 Percent of population infected per country 

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [dbo].[CovidDeaths]
Group by Location, Population
order by PercentPopulationInfected desc



-- 6 Percent people infected in south asia

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [dbo].[CovidDeaths]
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

--Highest Infected rate countries compared to population
	SELECT continent, location,MAX(total_cases) AS Total_cases, population, MAX(total_cases/population)*100 AS PopulationInfectedPercentage
	FROM [dbo].[CovidDeaths]
	WHERE continent is not null
	Group BY location, population, continent
	ORDER BY PopulationInfectedPercentage DESC








-- SHow data for South Asia
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

	SELECT d.continent, d.location,d.population,d.date, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY d.location order by d.date) as Rollingpeoplevaccinated,
		CASE
			WHEN d.location IN ('Bangladesh', 'India', 'Pakistan', 'Afghanistan', 'Maldives', 'Sri Lanka','Myanmar','nepal','Bhutan')  THEN 'South Asia'
			ELSE NULL -- creates a temporary column
		END AS SubContinent
	 
	FROM [dbo].[CovidDeaths] as d
	Join [dbo].[CovidVaccinations] as vac
		ON d.location=vac.location
		and d.date=vac.date 
	WHERE
	CASE
			WHEN d.location IN ('Bangladesh', 'India', 'Pakistan', 'Afghanistan', 'Maldives', 'Sri Lanka','Myanmar','nepal','Bhutan') THEN 'South Asia'
			ELSE NULL -- creates a temporary column
		END ='South Asia'
	 and vac.new_vaccinations is not null
	and d.continent='Asia' 
	order by d.location 


	--pop vs vc in south asis 
	-- Using CTE to perform Calculation on Partition By in previous query

	WITH popvsvac(continent, location,population,date,new_vaccinations, Rollingpeoplevaccinated, SubContinent)
	AS
	(
SELECT d.continent, d.location,d.population,d.date, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY d.location order by d.date) as Rollingpeoplevaccinated,
		CASE
			WHEN d.location IN ('Bangladesh', 'India', 'Pakistan', 'Afghanistan', 'Maldives', 'Sri Lanka','Myanmar','nepal','Bhutan')  THEN 'South Asia'
			ELSE NULL -- creates a temporary column
		END AS SubContinent
	 
	FROM [dbo].[CovidDeaths] as d
	Join [dbo].[CovidVaccinations] as vac
		ON d.location=vac.location
		and d.date=vac.date 
	WHERE
	CASE
			WHEN d.location IN ('Bangladesh', 'India', 'Pakistan', 'Afghanistan', 'Maldives', 'Sri Lanka','Myanmar','nepal','Bhutan') THEN 'South Asia'
			ELSE NULL -- creates a temporary column
		END ='South Asia'
	 and vac.new_vaccinations is not null
	and d.continent='Asia' 
	)

	SELECT *, (Rollingpeoplevaccinated/population)* 100 as Percentageofpeoplevacc
	FROM popvsvac 
	ORDER BY Percentageofpeoplevacc DESC 