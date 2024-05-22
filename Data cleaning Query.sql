--*Limpeza de dados*--
select * from PortfolioProjetos.dbo.NashvilleImoveis
-----------------------------------------------------------------------------------------------------------------------
--Padronizando formato de datas
select SaleDate from PortfolioProjetos.dbo.NashvilleImoveis
select SaleDate, convert (date, SaleDate) from PortfolioProjetos.dbo.NashvilleImoveis

update NashvilleImoveis set SaleDate = convert (date, SaleDate)
select SaleDate from PortfolioProjetos.dbo.NashvilleImoveis --Não funcionou

alter table NashvilleImoveis add DataConvertida date;
update NashvilleImoveis set DataConvertida = convert (date, SaleDate)
select DataConvertida from PortfolioProjetos.dbo.NashvilleImoveis

-----------------------------------------------------------------------------------------------------------------------
--Populando endereços null
select * from PortfolioProjetos.dbo.NashvilleImoveis where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProjetos.dbo.NashvilleImoveis a
join PortfolioProjetos.dbo.NashvilleImoveis b
on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjetos.dbo.NashvilleImoveis a
join PortfolioProjetos.dbo.NashvilleImoveis b
on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------
--Quebrando endereços em colunas distintas (separando endereço e estado), propertyaddress e owneraddress
select PropertyAddress from PortfolioProjetos.dbo.NashvilleImoveis 
select 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)) as Endereço
from PortfolioProjetos.dbo.NashvilleImoveis

select 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) as Endereço----tirando a virgula
from PortfolioProjetos.dbo.NashvilleImoveis

select 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) as Endereço, 
SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, len(PropertyAddress)) as Estado
from PortfolioProjetos.dbo.NashvilleImoveis

alter table NashvilleImoveis add Endereço_conv nvarchar(255);
update NashvilleImoveis set Endereço_conv = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)

alter table NashvilleImoveis add Estado nvarchar(255);
update NashvilleImoveis set Estado = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, len(PropertyAddress)) 
----------
select OwnerAddress from PortfolioProjetos.dbo.NashvilleImoveis 

select PARSENAME(replace(OwnerAddress,',', '.'),3), --parsename funciona com .
 PARSENAME(replace(OwnerAddress,',', '.'),2),
 PARSENAME(replace(OwnerAddress,',', '.'),1)
from PortfolioProjetos.dbo.NashvilleImoveis 

alter table NashvilleImoveis add Endereço_Owner_conv nvarchar(255);
update NashvilleImoveis set Endereço_Owner_conv  = PARSENAME(replace(OwnerAddress,',', '.'),3)

alter table NashvilleImoveis add Cidade_Owner nvarchar(255);
update NashvilleImoveis set Cidade_Owner = PARSENAME(replace(OwnerAddress,',', '.'),2)

alter table NashvilleImoveis add Estado_Owner nvarchar(255);
update NashvilleImoveis set Estado_Owner =  PARSENAME(replace(OwnerAddress,',', '.'),1)
---------------------------------------------------------------------------------------------
----Mudar Y e N para yes e no na tabela de vendas
select distinct(SoldAsVacant), COUNT(SoldAsVacant) from PortfolioProjetos.dbo.NashvilleImoveis 
group by SoldAsVacant

select SoldAsVacant, case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProjetos.dbo.NashvilleImoveis 

update PortfolioProjetos.dbo.NashvilleImoveis  set 
SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

---------------------------------------------------------------
---Excluir Duplicatas
------criar CTE
with ColNumCTE as (
	select *, ROW_NUMBER() OVER (
		partition by ParcelID, PropertyAddress,SalePrice, SaleDate, LegalReference
		order by UniqueId
		) col_num
from PortfolioProjetos.dbo.NashvilleImoveis 
)
Delete from  ColNumCTE where col_num >1 

----------------------------------
--Excluir colunas não usadas

alter table PortfolioProjetos.dbo.NashvilleImoveis drop column SaleDate, OwnerAddress, PropertyAddress, TaxDistrict