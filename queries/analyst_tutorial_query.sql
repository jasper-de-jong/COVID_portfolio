-- Portfolio project Project Alex the Analyst

-- This is the query he wrote in his youtube video
-- https://www.youtube.com/watch?v=qfyynHBFOsM&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=1
-- I made a few small custom changes (e.g. alias names), but they don't affect the numbers
-- Note that the actual numbers in the data tables are somewhat different from the ones in his video

-- Also, I already changed data types (numeric, character etc.) when importing the data.
-- so I don't deal with the CAST queries

-- Select data that we'll be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

-- Looking at the total_cases vs total_deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percent_of_cases
From PortfolioProject..CovidDeaths
-- To check specific country:
-- Where location = 'Netherlands'
Order by 1, 2

-- Looking at the highest infection rates per country
Select location, 
		population, 
		MAX(total_cases) AS max_infection_count, -- Get the highest (i.e. latest) nr of infections
		MAX(total_cases/population)*100 AS max_percent_infected -- As percent of population
From PortfolioProject..CovidDeaths
Group by location, population
Order by max_percent_infected Desc

-- Showing total death count per population
Select location, 
		population, 
		MAX(total_deaths) AS max_deaths_count,
		MAX(total_deaths/population)*100 AS max_percent_deaths_pop
From PortfolioProject..CovidDeaths
-- Because continent/location is not as expected here and there, we get rid of
-- rows where continent is NULL
Where continent Is Not NULL
Group by location, population
Order by location

-- Showing total death count per population per continent
-- We first have to subquery to calculate population per continent and use that to calculate percent

-- Step 1: CTE to get population and overall total deaths per location
With loc AS (
	Select continent,
			location,
			MAX(population) AS pop_loc,
			MAX(total_deaths) AS total_deaths_loc
	From PortfolioProject..CovidDeaths
	Where continent Is Not NULL -- Remove issues where continent is NULL
	Group by continent, location)
-- Step 3: Calculate percent deaths of population per continent
Select cont.continent,
		cont.pop_cont,
		cont.total_deaths_cont,
		ROUND((cont.total_deaths_cont/cont.pop_cont)*100, 3) AS percent_deaths_pop_cont
-- Step 2: Calculate population and total deaths per continent
From (
	Select loc.continent,
			SUM(loc.pop_loc) AS pop_cont,
			SUM(loc.total_deaths_loc) AS total_deaths_cont
	From loc
	Group by continent
	) AS cont



-- Combinations of Deaths and Vaccinations tables

-- Look at population that is vaccinated per continent

-- Step 1: Table with data per location
With loc AS(
	Select dea.continent, dea.location,
			MAX(dea.population) AS pop_loc,
			MAX(vac.people_fully_vaccinated) AS fully_vax_loc
	From PortfolioProject..CovidDeaths AS dea
		Join PortfolioProject..CovidVaccinations AS vac
		On dea.location = vac.location AND
			dea.date = vac.date	
	Where dea.continent Is Not NULL
	Group by dea.continent, dea.location
	)
-- Step 3: Calculate percentage fully vaccinated of population per continent
Select cont.continent,
		cont.pop_cont,
		cont.fully_vax_cont,
		ROUND((cont.fully_vax_cont/cont.pop_cont)*100, 3) AS percent_fully_vax_of_pop
From (
-- Step 2 calculate data per continent
Select loc.continent,
		SUM(loc.pop_loc) AS pop_cont,
		SUM(loc.fully_vax_loc) AS fully_vax_cont
From loc
Group by loc.continent) AS cont



-- Let's try the same, but using window functions
-- Start with CTE to get numbers per location (omit date as factor)
With loc AS(
	Select dea.continent, dea.location,
	-- For each country get the population size (here I take the max available value)
			MAX(dea.population) AS pop_loc,
	-- For each country get the currently total fully vaxxed people
			MAX(vac.people_fully_vaccinated) AS fully_vax_loc
	From PortfolioProject..CovidDeaths AS dea
		Join PortfolioProject..CovidVaccinations AS vac
		On dea.location = vac.location AND
			dea.date = vac.date	
	Where dea.continent Is Not NULL
	-- Group to get data per country
	Group by dea.continent, dea.location
	)
-- From this table, calculate per continent: population, fully vaxxed people and percentage
Select continent,
		MAX(pop_cont) AS pop_cont,
		MAX(fully_vax_cont) AS fully_vax_cont,
		ROUND((MAX(fully_vax_cont)/MAX(pop_cont))*100, 3) AS percent_fully_vax_pop_cont
From (
Select loc.continent,
		SUM(loc.pop_loc) OVER (Partition by loc.continent) AS pop_cont,
		SUM(loc.fully_vax_loc) OVER (Partition by loc.continent) AS fully_vax_cont
From loc ) As cont
Group by continent


-- Quick test with sliding window function
-- Calculate running total of cases over time in NL and compare to total_cases
Select location,
		date,
		new_cases,
		SUM(new_cases) OVER (Order by location, date 
							 Rows Between Unbounded Preceding And Current Row) As rolling_cases,
		total_cases
From PortfolioProject..CovidDeaths
Where location = 'Netherlands'


-- Same but for each country separately
Select location,
		date,
		new_cases,
		SUM(new_cases) OVER (Partition by location Order by location, date 
							 Rows Between Unbounded Preceding And Current Row) As rolling_cases,
		total_cases
From PortfolioProject..CovidDeaths
Where location in ('Netherlands', 'Sweden', 'United States')