Select * from Portfolioproject..coviddeaths
Order By 3,4


--Select * from Portfolioproject..covidvaccination
--Order By 3,4

Select location,date,total_cases,new_cases,total_deaths,population 
From  Portfolioproject..coviddeaths
Order by 1,2
--Total_cases vs total_deaths

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
From  Portfolioproject..coviddeaths
Where location Like '%India%'
Order by 1,2

-- Total cases vs population
Select location,date,total_cases,population,(total_cases/population)*100 as covid_percentage
From  Portfolioproject..coviddeaths
Where location Like '%India%'
Order by 1,2

--Highest infected population all over the world
Select location,population,max(total_cases) as HigestInfectionCount ,max((total_cases/population))*100 as Infected_percentage
From  Portfolioproject..coviddeaths
--Where location Like '%India%'
Group by location,population
Order by Infected_percentage desc

--Highest death percentage all over the world
Select location,population,max(total_deaths) as HigestDeathCount 
From  Portfolioproject..coviddeaths
--Where location Like '%India%'
Where continent is not Null
Group by location,population
Order by HigestDeathCount  desc

--Highest death percentage all over the world grouped by Continent
Select continent,max(total_deaths) as HigestDeathCount 
From  Portfolioproject..coviddeaths
--Where location Like '%India%'
Where continent is not Null
Group by continent
Order by HigestDeathCount  desc

--Global numbers
Select date, sum(new_cases) as global_cases,sum(new_deaths) as global_deaths,sum(new_deaths)/sum(new_cases)*100 as global_death_percentage
From  Portfolioproject..coviddeaths
Where continent is not Null
Group by date
Having sum(new_cases) <> 0
Order by 1,2

--Aggregate Global numbers
Select sum(new_cases) as global_cases,sum(new_deaths) as global_deaths,sum(new_deaths)/sum(new_cases)*100 as global_death_percentage
From  Portfolioproject..coviddeaths
Where continent is not Null
--Group by date
Having sum(new_cases) <> 0
Order by 1,2


--Population vs vaccinations
Select * ,sum(sub.new_vaccinations) over (Partition by sub.location Order by sub.location,sub.date ) as Rolling_vaccinations
from (Select Distinct d.continent,d.location, d.date,d.population,v.new_vaccinations
From Portfolioproject..coviddeaths d Join Portfolioproject..covidvaccination v 
on d.location = v.location And  d.date = v.date
Where d.continent is not null) as sub


-- Usage of CTE
With popvac (continent,location,date,population,new_vaccinations,Rolling_vaccinations)
as(
Select * ,sum(sub.new_vaccinations) over (Partition by sub.location Order by sub.location,sub.date ) as Rolling_vaccinations
from (Select Distinct d.continent,d.location, d.date,d.population,v.new_vaccinations
From Portfolioproject..coviddeaths d Join Portfolioproject..covidvaccination v 
on d.location = v.location And  d.date = v.date
Where d.continent is not null) as sub)

Select *,(Rolling_vaccinations/population)*100 as vaccinatedPercentage From popvac

--Temp table
Drop Table If exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric)
Insert into #PercentPeopleVaccinated
Select * ,sum(CAST(sub.new_vaccinations as bigint)) over (Partition by sub.location Order by sub.location,sub.date ) as Rolling_vaccinations
from (Select Distinct d.continent,d.location, d.date,d.population,v.new_vaccinations
From Portfolioproject..coviddeaths d Join Portfolioproject..covidvaccination v 
on d.location = v.location And  d.date = v.date) as sub
--Where d.continent is not null) as sub

Select *,(Rolling_vaccinations/population)*100 as vaccinatedPercentage From #PercentPeopleVaccinated


--Create view for later use
Create view PercentPeopleVaccinated as
Select * ,sum(CAST(sub.new_vaccinations as bigint)) over (Partition by sub.location Order by sub.location,sub.date ) as Rolling_vaccinations
from (Select Distinct d.continent,d.location, d.date,d.population,v.new_vaccinations
From Portfolioproject..coviddeaths d Join Portfolioproject..covidvaccination v 
on d.location = v.location And  d.date = v.date) as sub

Select * from PercentPeopleVaccinated