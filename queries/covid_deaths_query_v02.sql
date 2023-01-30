-- Queries for my COVID portfolio project
-- I saved the results of these queries as excel files and 
-- Visualized the data in Tableau

-- Overview of the visualizations I want to create

-- #1: Table showing global total cases, total deaths and death as percentage of cases

-- #2: Bar graph showing deaths as percent of population (total) in the US, Sweden and Netherlands

-- #3: Line plot showing percent of population infected over time in US, Sweden and the Netherlands

-- #4: World map showing percent infected world wide

-- #5: Scatter plot percent_deaths vs percent_infected per country







-- Queries:

-- #1: 
-- Total cases and deaths and percent death of cases per continent
-- Use a common table expression to first return the MAX cases and deaths per continent
-- and then calculate the percentage on that table

With max AS (
	Select continent, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths
	From PortfolioProject..CovidDeaths
	-- There are fields where continent has value NULL
	-- Let's remove them from the queries
	Where continent Is Not NULL
	Group by continent)
Select continent, 
		total_cases, 
		total_deaths,
		(total_deaths/total_cases)*100 AS percent_death_cases
From max
Order by continent;


-- #2:
-- deaths as percent of population (total) in the US, Sweden and Netherlands

-- Start with a CTE (common table expression)
With sub AS (
Select location, population, 
		Max(total_deaths) AS max_total_deaths
From PortfolioProject..CovidDeaths
Where location In ('Sweden', 'Netherlands', 'United States') AND total_deaths Is Not NULL
Group by location, population
)
-- Then calculate percentage
Select location, population, max_total_deaths,
		Round((max_total_deaths/population)*100, 3) AS percent_deaths_pop
From sub
Order by location, max_total_deaths Desc -- Order by needs to be outside of CTE

-- #3
-- Percent infected in US, Sweden Netherlands over time
-- Start with a CTE to make the calculations faster
With sub AS (
	Select location, 
			date, 
			population,
			total_cases,
			total_deaths
	From PortfolioProject..CovidDeaths
	Where location In ('Sweden', 'Netherlands', 'United States')
)
Select location, 
		date,
		total_cases,
		total_deaths,
		(total_cases/population)*100 AS percent_infected,
		(total_deaths/total_cases)*100 AS percent_death_cases
From sub
Order by location, date

-- #4
-- Total percent infected per country/location
With sub AS (
Select location, continent, date, total_cases, 
	(total_cases/population)*100 AS percent_infected_pop
From PortfolioProject..CovidDeaths
)
Select location, 
	MAX(percent_infected_pop) AS percent_infected_pop
From sub
Where continent Is Not NULL
Group by location
Order by percent_infected_pop Desc;


-- #5
-- percent_cases vs percent_deaths by location
-- Similar to #4, but add percent_deaths of population

Use [PortfolioProject]

GO

Create View percent_cases_deaths_pop_by_location AS
With sub AS (
Select location, continent, date, total_cases, 
	(total_cases/population)*100 AS percent_infected_pop,
	(total_deaths/population)*100 AS percent_deaths_pop
From PortfolioProject..CovidDeaths
)
Select location, continent,
	MAX(percent_infected_pop) AS percent_infected_pop,
	MAX(percent_deaths_pop) AS percent_deaths_pop
From sub
Where continent Is Not NULL
Group by continent, location
Order by percent_infected_pop Desc;

