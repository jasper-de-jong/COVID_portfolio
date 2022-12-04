-- Portfolio project on Covid data 
-- Following Alex the Analyst's tutorial on
-- https://www.youtube.com/watch?v=qfyynHBFOsM&t=906s


-- Generating the data we need
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Compares deaths up to a given day to cases up to that day. 
-- Shows deaths as a percent of cases up to that point in time.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percent
From PortfolioProject..CovidDeaths
Where location like 'Netherlands'
order by 1, 2

-- Looking at Total Cases vs Population
-- Compares cases on a given day to population size. Shows percent of population infected (and reported).
-- Note that total_cases is cumulative over time.
Select location, date, total_cases, population, total_deaths, (total_cases/population)*100 AS cases_percent
From PortfolioProject..CovidDeaths
Where location like 'Netherlands'
order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population
-- Show number of reported cases over time as percent of population
-- I assume total_cases contains repeated cases, so likely to be an overestimation.
Select location, population, MAX(total_cases) AS max_infection_count, MAX(total_cases/population)*100 AS max_cases_percent
From PortfolioProject..CovidDeaths
Group by location, population
order by max_cases_percent desc
