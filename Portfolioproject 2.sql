SELECT *
FROM Nashville.dbo.[Nashville Housing]

--CORRECTING DATE FORMAT 
SELECT saledateconverted,Convert(date,saledate)
FROM Nashville.dbo.[Nashville Housing]

UPDATE [Nashville Housing]
SET Saledate = Convert(date,saledate)

ALTER TABLE [Nashville Housing]
ADD Saledateconverted date;

UPDATE [Nashville Housing]
SET Saledateconverted = Convert(date,saledate)


--POPULATE PROPERTY ADDRESS DATA

SELECT PropertyAddress
FROM Nashville.dbo.[Nashville Housing]

SELECT N1.ParcelID,N1.PropertyAddress,N2.ParcelID,N2.PropertyAddress, ISNULL(N1.PROPERTYADDRESS,N2.PropertyAddress)
FROM Nashville.dbo.[Nashville Housing] N1
JOIN Nashville.dbo.[Nashville Housing] N2
 ON N1.ParcelID = N2.ParcelID
 AND N1.[UniqueID ] <> N2.[UniqueID ]
 WHERE N1.PropertyAddress IS NULL


UPDATE N1
SET PropertyAddress = ISNULL(N1.PROPERTYADDRESS,N2.PropertyAddress)
FROM Nashville.dbo.[Nashville Housing] N1
JOIN Nashville.dbo.[Nashville Housing] N2
 ON N1.ParcelID = N2.ParcelID
 AND N1.[UniqueID ] <> N2.[UniqueID ]
 WHERE N1.PropertyAddress IS NULL

 --BREAKING ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS,CITY,STATE)

 SELECT PropertyAddress
FROM Nashville.dbo.[Nashville Housing]

SELECT
SUBSTRING(PROPERTYADDRESS,1,CHARINDEX(',',propertyaddress)-1) as Address,
SUBSTRING(PROPERTYADDRESS,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress)) as Address
FROM Nashville.dbo.[Nashville Housing]

ALTER TABLE Nashville.dbo.[NASHVILLE HOUSING]
ADD Propertysplitaddress NVARCHAR(225);

UPDATE Nashville.dbo.[NASHVILLE HOUSING]
SET Propertysplitaddress = SUBSTRING(PROPERTYADDRESS,1,CHARINDEX(',',propertyaddress)-1)

ALTER TABLE Nashville.dbo.[NASHVILLE HOUSING]
ADD Propertysplitcity NVARCHAR(225);

UPDATE Nashville.dbo.[NASHVILLE HOUSING]
SET Propertysplitcity = SUBSTRING(PROPERTYADDRESS,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))

SELECT *
FROM Nashville.dbo.[Nashville Housing]

SELECT Owneraddress
FROM Nashville.dbo.[Nashville Housing]

SELECT
PARSENAME (REPLACE(Owneraddress,',','.') , 3),
PARSENAME (REPLACE(Owneraddress,',','.') , 2),
PARSENAME (REPLACE(Owneraddress,',','.') , 1)
FROM Nashville.dbo.[Nashville Housing]

ALTER TABLE Nashville.dbo.[NASHVILLE HOUSING]
ADD Ownersplitaddress NVARCHAR(225);

UPDATE Nashville.dbo.[NASHVILLE HOUSING]
SET Ownersplitaddress = PARSENAME (REPLACE(Owneraddress,',','.') , 3)

ALTER TABLE Nashville.dbo.[NASHVILLE HOUSING]
ADD Ownersplitcity NVARCHAR(225);

UPDATE Nashville.dbo.[NASHVILLE HOUSING]
SET Ownersplitcity = PARSENAME (REPLACE(Owneraddress,',','.') , 2)

ALTER TABLE Nashville.dbo.[NASHVILLE HOUSING]
ADD Ownersplitstate NVARCHAR(225);

UPDATE Nashville.dbo.[NASHVILLE HOUSING]
SET Ownersplitstate = PARSENAME (REPLACE(Owneraddress,',','.') , 1)

-- Changing Y and N To Yes and No in "Sold as Vacant field"

SELECT DISTINCT (Soldasvacant),COUNT(Soldasvacant)
FROM Nashville.dbo.[Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT Soldasvacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Nashville.dbo.[Nashville Housing]

UPDATE Nashville.dbo.[Nashville Housing]
SET Soldasvacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- REMOVING DUPLICATES

WITH RownumCTE AS (
SELECT *,
   ROW_NUMBER () OVER (
   PARTITION BY ParcelID,
                Propertyaddress,
				Saleprice,
				Saledate,
				Legalreference
				ORDER BY
				UniqueID
				) Row_Num
FROM Nashville.dbo.[Nashville Housing]
)
DELETE
FROM RownumCTE
WHERE Row_Num > 1
--ORDER BY PropertyAddress


--REMOVING UNUSED COLUMNS

ALTER TABLE Nashville.dbo.[Nashville Housing]
DROP COLUMN Owneraddress,Taxdistrict,Propertyaddress

ALTER TABLE Nashville.dbo.[Nashville Housing]
DROP COLUMN saledate