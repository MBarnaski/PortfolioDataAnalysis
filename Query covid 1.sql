--select * from PortfolioProjetos.dbo.['owid-covid-deaths']
--select * from PortfolioProjetos.dbo.['owid-covid-vaccines']
--select location, date, total_cases, new_cases, total_deaths, population from PortfolioProjetos.dbo.['owid-covid-deaths']
--where continent is not null
--order by 1,2

---- Casos vs Mortes, probabilidade de morte ap�s infec��o por pa�s
----select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100  as PorcentagemMortes 
----from PortfolioProjetos.dbo.['owid-covid-deaths']
----where location like '%brazil%'
----order by 1,2

------Casos totais vs popula��o, porcentagem da popul�ao que contraiu covid
----select location, date, total_cases, population, (cast(total_cases as float)/population)*100  as PorcentagemInfeccoes 
----from PortfolioProjetos.dbo.['owid-covid-deaths']
------where location like '%brazil%' and continent is not null
----order by 1,2

----Pa�ses com maior taxa de infec��o em rela��o a popula��o
----select location, population, max(cast (total_cases as float)) as MaiorTaxaInfeccao, max(cast(total_cases as float)/population)*100  as PorcentagemInfeccoes 
----from PortfolioProjetos.dbo.['owid-covid-deaths']
------where location like '%brazil%' and continent is not null
----group by location, population
----order by PorcentagemInfeccoes desc

----Pa�ses com maior taxa de mortes em rela��o a popula��o
----select location, max(cast (total_deaths as int)) as MaiorTaxaMortes
----from PortfolioProjetos.dbo.['owid-covid-deaths']
------where location like '%brazil%'
----where  continent is not null
----group by PortfolioProjetos.dbo.['owid-covid-deaths'].location 
----order by MaiorTaxaMortes desc

----Por continente
--select location, max(cast (total_deaths as int)) as MaiorTaxaMortes
--from PortfolioProjetos.dbo.['owid-covid-deaths']
----where location like '%brazil%'
--Where continent is not null
--group by location
--order by MaiorTaxaMortes desc

----N�meros totais globais
--select sum(new_cases) as TotalDeCasos, sum(new_deaths) TotalDeMortes, SUM(new_deaths)/NULLIF(sum(new_cases),0)*100
--from PortfolioProjetos.dbo.['owid-covid-deaths']
----where location like '%brazil%'
--where continent is not null
----group by date
--order by 1,2

--join
select * from PortfolioProjetos.dbo.['owid-covid-deaths'] as mortes join PortfolioProjetos.dbo.['owid-covid-vaccines'] as vac
on mortes.location = vac.location and mortes.date=vac.date

--Total de popula��o vs Vacinados
--cte
with PopVsCont (continent, Location, Date, Population, new_vaccinations, PessoasVacinadas)
as(
select mortes.continent, mortes.location, mortes.date, mortes.population, vac.new_vaccinations, 
sum(convert(real, vac.new_vaccinations)) over (partition by mortes.location order by mortes.location,mortes.date)
PessoasVacinadas
from PortfolioProjetos.dbo.['owid-covid-deaths'] as mortes join PortfolioProjetos.dbo.['owid-covid-vaccines'] as vac
on mortes.location = vac.location and mortes.date=vac.date
where mortes.continent is not null
)
select *, (PessoasVacinadas/Population)*100 from PopVsCont 

--temp table
drop table if exists #tempPorcentagemPopula��oVacinada
create table #tempPorcentagemPopula��oVacinada(
continent nvarchar (255),
location nvarchar (255),
data datetime,
population real,
new_vaccination real,
PessoasVacinadas real
)
insert into #tempPorcentagemPopula��oVacinada
select mortes.continent, mortes.location, mortes.date, mortes.population, vac.new_vaccinations, 
sum(convert(real, vac.new_vaccinations)) over (partition by mortes.location order by mortes.location,mortes.date)
PessoasVacinadas
from PortfolioProjetos.dbo.['owid-covid-deaths'] as mortes join PortfolioProjetos.dbo.['owid-covid-vaccines'] as vac
on mortes.location = vac.location and mortes.date=vac.date
--where mortes.continent is not null
select *, (PessoasVacinadas/Population)*100 from #tempPorcentagemPopula��oVacinada 

--criar view para consultas futuras
create view PorcentagemPopulacaoVacinada as
select mortes.continent, mortes.location, mortes.date, mortes.population, vac.new_vaccinations, 
sum(convert(real, vac.new_vaccinations)) over (partition by mortes.location order by mortes.location,mortes.date)
PessoasVacinadas
from PortfolioProjetos.dbo.['owid-covid-deaths'] as mortes join PortfolioProjetos.dbo.['owid-covid-vaccines'] as vac
on mortes.location = vac.location and mortes.date=vac.date
where mortes.continent is not null


select * from PorcentagemPopulacaoVacinada

