-- cleaning data in SQL 

Select * 
FROM Nashville_Housing_Data_for_Data_Cleaning nh


-- Date formatting 

SELECT SaleDate, DATE(SaleDate) AS ConvertedSaleDate
FROM Nashville_Housing_Data_for_Data_Cleaning nh;

----------------------------------------------------------------------------------------------------------------------------------

-- populate Property Address Data 

SELECT PropertyAddress
FROM Nashville_Housing_Data_for_Data_Cleaning nh 
WHERE TRIM(PropertyAddress) = ''; --check for empty cells 

-- join with itsself, check where parcel ID is same and Property Address empty, populate empty cells with correct address 

SELECT 
    a.ParcelID AS ParcelID_a, 
    a.PropertyAddress AS PropertyAddress_a, 
    b.ParcelID AS ParcelID_b, 
    b.PropertyAddress AS PropertyAddress_b, 
    COALESCE(NULLIF(TRIM(a.PropertyAddress), ''), b.PropertyAddress) AS CombinedPropertyAddress
FROM 
    Nashville_Housing_Data_for_Data_Cleaning a
JOIN 
    Nashville_Housing_Data_for_Data_Cleaning b ON a.ParcelID = b.ParcelID 
                                                AND a."UniqueID " <> b."UniqueID "
WHERE 
    TRIM(a.PropertyAddress) = '';
   
   UPDATE Nashville_Housing_Data_for_Data_Cleaning AS a
SET PropertyAddress = COALESCE(NULLIF(TRIM(a.PropertyAddress), ''), b.PropertyAddress)
FROM Nashville_Housing_Data_for_Data_Cleaning AS b
WHERE a.ParcelID = b.ParcelID 
      AND a."UniqueID " <> b."UniqueID "
      AND TRIM(a.PropertyAddress) = '';

 
----------------------------------------------------------------------------------------------------------------------------------

-- Split Address into Individual columns (Address, City, State) 
     
     Select 
     SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address --get rid of comma 
     , SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LENGTH(PropertyAddress)) as City
     From Nashville_Housing_Data_for_Data_Cleaning nh
   
ALTER Table Nashville_Housing_Data_for_Data_Cleaning 
Add PropertySplitAddress Nvarchar(255) 

Update Nashville_Housing_Data_for_Data_Cleaning 
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER Table Nashville_Housing_Data_for_Data_Cleaning 
Add PropertySplitCity Nvarchar(255) 

Update Nashville_Housing_Data_for_Data_Cleaning 
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LENGTH(PropertyAddress))



SELECT 
    TRIM(SUBSTR(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1)) AS OwnerStreet,
    TRIM(SUBSTR(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 1)) AS OwnerCity,
    TRIM(SUBSTR(OwnerAddress, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) + 1)) AS OwnerState
FROM 
    Nashville_Housing_Data_for_Data_Cleaning;

ALTER Table Nashville_Housing_Data_for_Data_Cleaning 
Add OwnerStreet Nvarchar(255) 

Update Nashville_Housing_Data_for_Data_Cleaning 
Set OwnerStreet = TRIM(SUBSTR(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1))

ALTER Table Nashville_Housing_Data_for_Data_Cleaning 
Add OwnerCity Nvarchar(255) 

Update Nashville_Housing_Data_for_Data_Cleaning 
Set OwnerCity = TRIM(SUBSTR(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 1))

ALTER Table Nashville_Housing_Data_for_Data_Cleaning 
Add OwnerState Nvarchar(255) 

UPDATE Nashville_Housing_Data_for_Data_Cleaning 
SET OwnerState = TRIM(SUBSTR(OwnerAddress, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) + 1));


Select * 
FROM Nashville_Housing_Data_for_Data_Cleaning nh

----------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to yes and no in "Sold as Vacant"

Select DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) 
from Nashville_Housing_Data_for_Data_Cleaning nh
Group by SoldAsVacant 
Order by 2

SELECT 
    SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS TransformedSoldAsVacant
FROM 
    Nashville_Housing_Data_for_Data_Cleaning nh;
   
UPDATE Nashville_Housing_Data_for_Data_Cleaning 
SET SoldAsVacant = CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END 
    

----------------------------------------------------------------------------------------------------------------------------------

-- Remove duplicates 
    
SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, COUNT(*)
FROM Nashville_Housing_Data_for_Data_Cleaning
GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Having count(*)>1

DELETE FROM Nashville_Housing_Data_for_Data_Cleaning 
WHERE (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference) IN (
    SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    FROM Nashville_Housing_Data_for_Data_Cleaning
    GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    HAVING COUNT(*) > 1
);



