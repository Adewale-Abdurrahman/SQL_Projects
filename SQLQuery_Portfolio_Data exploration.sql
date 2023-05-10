Select *
From Portfolio_Project..Covid_Deaths
Where continent is not null
Order by 3,4

Select *
From Portfolio_Project..Covid_Vaccination
Where continent is not null
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..Covid_Deaths
Order by 1,2

-- Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
From Portfolio_Project..Covid_Deaths
Where location = 'Nigeria' 
Order by 1,2 


-- Looking at the total cases vs Popuation
-- Shows what percentage of the poppuation contracted covid

Select location, date,population, total_cases, (total_cases/population)*100 AS Percent_Population_infected
From Portfolio_Project..Covid_Deaths
Where location = 'Nigeria'
Order by 1,2 

-- Looking  at countries with highest infection rate compared to population

Select location,population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_infected
From Portfolio_Project..Covid_Deaths
Where continent is not null
--Where location = 'Nigeria'
Group by location,population
Order by Percent_Population_infected DESC


-- Showing Countries with Highest Mortality rate

Select location,population, MAX(cast(total_deaths as int)) AS Total_Death_count
From Portfolio_Project..Covid_Deaths
Where continent is not null
Group by location,population
Order by Total_Death_count DESC


-- Let's break things down by continents
-- Showing the continents with the highest deathcount

Select continent, MAX(cast(total_deaths as int)) AS Total_Death_count
From Portfolio_Project..Covid_Deaths
Where continent is not null
Group by continent
Order by Total_Death_count DESC


--Global Numbers

Select date, Sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int))/Sum(new_cases))*100 AS Death_Percentage
From Portfolio_Project..Covid_Deaths
Where continent is not null
Group by date
Order by 1,2


-- Looking at tota population vs vaccination

With PopVsVac (continent, location, date, population, New_vaccinations, Rolling_People_vaccinated ) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(Vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as Rolling_People_vaccinated
From Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccination vac
	ON dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (Rolling_People_vaccinated/population)*100
From PopVsVac


--TEMP TABLE

DROP TABLE IF exists #Percent_Popuation_Vaccinated
Create Table #Percent_Popuation_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Roling_People_vaccinated numeric
)

Insert into #Percent_Popuation_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(Vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as Roling_People_vaccinated
From Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccination vac
	ON dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (Roling_People_vaccinated/population)*100
From #Percent_Popuation_Vaccinated



-- Creating view to store data for later Visualisation

DROP VIEW IF exists Percentage_Popuation_Vaccinated
CREATE VIEW
Percentage_Popuation_Vaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(Vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as Roling_People_vaccinated
From Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccination vac
	ON dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From Percentage_Popuation_Vaccinated
