/*
Cleaning Data in SQL Queries

*/

SELECT * 
FROM [Portfolio Project].dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------
GO
--Standardize Date Format

SELECT SaleDate, CAST(SaleDate AS Date)
From NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate AS Date)

SELECT SaleDate
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD UpdatedSalesDate Date;

UPDATE NashvilleHousing
SET UpdatedSalesDate = CAST(SaleDate AS Date)

SELECT UpdatedSalesDate 
FROM NashvilleHousing


Go

--Populating Property Adress Data

SELECT *
FROM [dbo].[NashvilleHousing] 
WHERE PropertyAddress is NULL
ORDER By ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL



GO

----breaking out Address into individual  Columns(Address,city,state)
SELECT PropertyAddress
FROM [dbo].[NashvilleHousing] 

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM [dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

ALTER TABLE NashvilleHousing
DROP COLUMN PropertySplitCity;

SELECT * 
FROM [dbo].[NashvilleHousing]

Go

--Owner Address

SELECT OwnerAddress FROM NashvilleHousing 
--WHERE OwnerAddress is null

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM [dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


SELECT * 
FROM [dbo].[NashvilleHousing]

Go

-- Change Y and N to Yes and No in "Sold As Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER By 2

--USing CASE Statement

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM [dbo].[NashvilleHousing]


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END

GO

-----------------------------------------------------------------------------------------------
--Remove Duplicates

SELECT * 
FROM [Portfolio Project].dbo.NashvilleHousing

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num
FROM [Portfolio Project].dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY propertyAddress

GO


------------Delete Unused Columns-------------------------------

SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing


ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress


ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN SaleDate