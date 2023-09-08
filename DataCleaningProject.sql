-------CLEANING DATA-------

select *
from SQLPROJECTSSS.dbo.NashvilleHousing

select ConvertedSaleDate, Convert(Date,SaleDate)
from SQLPROJECTSSS.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = Convert(Date,SaleDate)

alter table NashvilleHousing
add ConvertedSaleDate Date;

update NashvilleHousing
set ConvertedSaleDate = Convert(Date,SaleDate)

---------------------------------------------------------------------------------------------

--Populate Property Address Data

select *
from SQLPROJECTSSS.dbo.NashvilleHousing
where PropertyAddress is null

--Since there is a pattern between ParcelID and PropertyAddress, we populate the PropertyAddress using the ParcelID and a unique coumn

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from SQLPROJECTSSS.dbo.NashvilleHousing a
join SQLPROJECTSSS.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from SQLPROJECTSSS.dbo.NashvilleHousing a
join SQLPROJECTSSS.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns (Address, city, state)

select PropertyAddress
from SQLPROJECTSSS.dbo.NashvilleHousing

--removing the commas separating the addresses

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from SQLPROJECTSSS.dbo.NashvilleHousing

--Creating 2 different Columns for the new addresses

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress))




select OwnerAddress
from SQLPROJECTSSS.dbo.NashvilleHousing

select
parsename(replace(OwnerAddress,',','.'),3)
, parsename(replace(OwnerAddress,',','.'),2)
, parsename(replace(OwnerAddress,',','.'),1)
from SQLPROJECTSSS.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)


--Changing Y and N to Yes and No in the "sold as vacant" field

select distinct SoldAsVacant, count(SoldAsVacant)
from SQLPROJECTSSS.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from SQLPROJECTSSS.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

--Deleting duplicates from the dataset


with row_numCTE as(
select *,
row_number() over(
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by UniqueID
				) row_num
from SQLPROJECTSSS.dbo.NashvilleHousing
)
select *    --Then change select to delete after checking
from row_numCTE
where row_num > 1
order by PropertyAddress





--Deleting unused colums from the dataset

select *
from SQLPROJECTSSS.dbo.NashvilleHousing

alter table SQLPROJECTSSS.dbo.NashvilleHousing
drop column TaxDistrict, OwnerAddress, PropertyAddress

alter table SQLPROJECTSSS.dbo.NashvilleHousing
drop column SaleDate