-- These are a series of queries to combine COVID cases, deaths and vaccination data
-- The point is to work with two tables and work on JOINs to combine data

-- What do we want to visualize eventually?

-- #1 Vaccinations in different countries over time
-- #2 Daily cases vs vaccinations over time (actual and rolling)
-- #3 Daily deaths vs vaccinations over time (actual and rolling)
-- #4 Percent of population vaccinated per country/continent


-- #1: Vaccinations per country over time


With sub AS	
(Select d.location, 
		d.continent,
		d.date,
		d.population,
		v.new_vaccinations,
		v.total_vaccinations,
		v.people_vaccinated
From PortfolioProject..CovidVaccinations AS v
Inner Join PortfolioProject..CovidDeaths AS d
ON d.location = v.location AND
	d.date = v.date
Where d.continent Is Not NULL)
Select location,
		continent,
		date,
		population,
		new_vaccinations,
		total_vaccinations,
		people_vaccinated,
		(people_vaccinated/population)*100 AS percent_pop_vax
From sub





-- #2: Cases and vaccinations over time by country
Select d.location, 
		d.date,
		d.total_cases,
		d.new_cases,
		v.new_vaccinations,
		v.total_vaccinations,
		v.people_vaccinated, 
		v.people_fully_vaccinated
FROM PortfolioProject..CovidDeaths AS d
INNER JOIN PortfolioProject..CovidVaccinations AS v
	ON d.location = v.location AND
	d.date = v.date