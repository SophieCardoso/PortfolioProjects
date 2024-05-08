SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths cd 
WHERE continent IS NOT NULL 

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN NULL 
        ELSE (total_deaths * 1.0 / total_cases) * 100 
    END AS Deathpercentage
FROM 
    CovidDeaths cd
    WHERE location LIKE '%Germany%';
    AND continent IS NOT NULL 
   -- total cases vs population 
   -- shows what percentage of population got covid 
   SELECT 
    location, 
    date, 
    total_cases, 
    population, 
    CASE 
        WHEN total_cases = 0 THEN NULL 
        ELSE (total_cases * 1.0 / population) * 100 
    END AS InfectedPercentage
FROM 
    CovidDeaths cd
    WHERE location LIKE '%Germany%';
   and continent IS NOT NULL 
   
   -- looking at countries with highest infection rate compared to population 
    SELECT 
    location, 
    population, 
    MAX(total_cases) as HighestInfectionCount, 
    CASE 
        WHEN MAX(total_cases) = 0 THEN NULL 
        ELSE MAX((total_cases * 1.0 / population)) * 100 
    END AS InfectedPercentage
FROM 
    CovidDeaths cd
    WHERE continent IS NOT NULL 
    Group by location, population   
    order by InfectedPercentage DESC 
    
    -- Countries with highest death toll per population 
   

SELECT 
    location,
    MAX(CAST(total_deaths AS INT)) AS MaxDeathTollPerPopulation
FROM 
    CovidDeaths cd
    WHERE continent IS NOT NULL AND continent <> '' 
GROUP BY 
    location
    order by MaxDeathTollPerPopulation desc;

-- break things down by continents 
   
-- Showing the continents with the highest death count 
     
  SELECT 
    continent,
    MAX(CAST(total_deaths AS INT)) AS MaxDeathTollPerPopulation
FROM 
    CovidDeaths cd
WHERE 
    continent IS NOT NULL AND continent <> ''
GROUP BY 
    continent
ORDER BY 
    MaxDeathTollPerPopulation DESC;
   
   
   -- Global numbers 
   
   SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
   SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as MaxDeathTollPerPopulation
   FROM 
    CovidDeaths cd
WHERE 
    continent IS NOT NULL AND continent <> ''
--Group by date 
order by 3,4


-- Looking at total population vs vaccination 

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(CAST(cv.new_vaccinations AS INTEGER)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated 
FROM CovidDeaths cd 
INNER JOIN CovidVaccinations cv 
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE 
    cd.continent IS NOT NULL AND cd.continent <> ''
ORDER BY 2, 3;


-- cte 

With PopVsVac (Continten, Location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(CAST(cv.new_vaccinations AS INTEGER)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated 
FROM CovidDeaths cd 
INNER JOIN CovidVaccinations cv 
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE 
    cd.continent IS NOT NULL AND cd.continent <> '')

Select *, (RollingPeopleVaccinated*1.0/population)*100
From PopVsVac;




-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as 

  SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(CAST(cv.new_vaccinations AS INTEGER)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated 
FROM CovidDeaths cd 
INNER JOIN CovidVaccinations cv 
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE 
    cd.continent IS NOT NULL AND cd.continent <> ''
    
    select * from PercentPopulationVaccinated
