-- Data cleaning in SQl using queries

select * from NashvilleHousing

--------------------------------------------------------------------------------------
--standerdizing sale date
--------------------------------------------------------------------------------------

select SaleDateConverted, convert(date, SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date, SaleDate)

alter table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)


--------------------------------------------------------------------------------------
-- Populate Property adress date
--------------------------------------------------------------------------------------

select *
from NashvilleHousing 
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------
-- Breaking out Address into individual Columns (Address, city, state)
--------------------------------------------------------------------------------------

-- Property address

select PropertyAddress
from NashvilleHousing 
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress,1 , CHARINDEX(',', PropertyAddress)-1) as address
,SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))as address
from NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1 , CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

select * from NashvilleHousing

--------------------------------------------------------------------------------------
-- owner adress
--------------------------------------------------------------------------------------

select OwnerAddress from NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvilleHousing

alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)


alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)


alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------------------
-- change y and n to yesd and on in sold in vacant field
--------------------------------------------------------------------------------------

select distinct(SoldAsVacant) ,count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

--------------------------------------------------------------------------------------
--remove duplicates
--------------------------------------------------------------------------------------

with RowNumCTE as(
Select *,
	ROW_NUMBER()over (
	partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		order by uniqueID
			) row_num
from NashvilleHousing
--order by ParcelID
)
select * from RowNumCTE
where row_num >1
order by PropertyAddress

--------------------------------------------------------------------------------------
-- delete unused columns
--------------------------------------------------------------------------------------

alter table NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate



