--Data Cleaning Project
--Data on Nashville Housing is from Kaggle

SELECT *
FROM NashvilleHousing

---------------------------------------------------------------------------------------------

--Standardizing the Date Format (We don't need the time data)

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date

---------------------------------------------------------------------------------------------

--Populating empty Property Address data
--Many of the property addresses were coming up blank, but there were also lots of duplicates in the data so the address could be found in another row. 
--The ParcelID matches the PropertyAddress, so I used a Self-Join to populate the ProperyAddress based on the ParcelID if it is blank.

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
ORDER BY a.ParcelID

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

---------------------------------------------------------------------------------------------

--Breaking out the PropertyAddress into Individual Columns (Address, City)
--Below I'm using substrings to find the comma and separate out the data

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM NashvilleHousing

--Then, I'm adding the cleaned data to the table.

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM NashvilleHousing

---------------------------------------------------------------------------------------------

--Now I'm going to do the same thing with the OwnerAddress, but in a different way.
--Below I'm using PARSENAME since each string we need is separated by a comma. 
--I am replacing the commas with a period, then separating them into three sections.

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) as OwnerAddress
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2) as OwnerCity
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1) as OwnerState
FROM NashvilleHousing

--Then, I'm adding the cleaned data to the table.

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1) 


---------------------------------------------------------------------------------------------
	
--Below I ran a Distinct count on the column SoldAsVacant and found that there were Yes,Y,No,N values. 
--I want to standardize this, so I'm going to change the Y & N to Yes & No.

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE	when SoldAsVacant = 'Y' THEN 'YES'
		when SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE	when SoldAsVacant = 'Y' THEN 'YES'
		when SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
	
---------------------------------------------------------------------------------------------

--Removing Duplicates 
--I'm putting data into a CTE in order to identify which rows that have the exact same data. 
--104 rows had the same data and I don't need them at all, so I changed the final SELECT * to DELETE and removed them.

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------

-- Finally, I'm going to Delete the old version of the Columns and the Columns I will not need.

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
