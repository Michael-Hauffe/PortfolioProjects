--Cleaning Publically Available Nashville Housing Data in SQL Queries

Select * 
From NashvillePortfolioProject.dbo.NashvilleHousing

--Change Sale Date Format
Select SaleDate, CONVERT(Date,SaleDate)
From NashvillePortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--Populate Property Address Data
Select * 
From NashvillePortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
From NashvillePortfolioProject.dbo.NashvilleHousing as a
join NashvillePortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--replacing null values for PropertyAddress with correct values from different row with the same ParcelID
update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvillePortfolioProject.dbo.NashvilleHousing a
join NashvillePortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Select PropertyAddress 
From NashvillePortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

--Separating PropertyAddress by the delimiter ","
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From NashvillePortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvillePortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvillePortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvillePortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvillePortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



--Separating OwnerAddress by the delimiter ","
select OwnerAddress
from NashvilleHousing

SELECT
parsename(REPLACE(OwnerAddress, ',','.'),3),
parsename(REPLACE(OwnerAddress, ',','.'),2),
parsename(REPLACE(OwnerAddress, ',','.'),1)
from NashvillePortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvillePortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvillePortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = parsename(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvillePortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvillePortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = parsename(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvillePortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvillePortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = parsename(REPLACE(OwnerAddress, ',','.'),1)


--Changing SoldAsVacant 'Y' values to 'Yes' and 'N' to 'No'

SELECT DISTINCT(SoldAsVacant), COUNT(soldasvacant)
FROM NashvillePortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2



Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvillePortfolioProject.dbo.NashvilleHousing
order by SoldAsVacant

update NashvillePortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

--Backup full table
Select * INTO NashvilleHousingBackup
FROM NashvillePortfolioProject.dbo.NashvilleHousing

--Remove Duplicates. Normally, I would make a temp table with duplicates removed
--but I want to showcase my abilities

WITH RowNumCTE AS (
SELECT * ,
ROW_NUMBER() OVER(
Partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
				UniqueID
				) as row_num


FROM NashvillePortfolioProject.dbo.NashvilleHousing
)
DELETE FROM RowNumCTE --First wrote 'Select *' instead of 'DELETE' to check I was deleting the right rows. I then edited it to say 'DELETE'
WHERE Row_num > 1

--Delete Unused Columns
SELECT *
FROM NashvillePortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvillePortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate








































