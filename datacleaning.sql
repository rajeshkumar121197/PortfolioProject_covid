--Cleaning data in Ms Sql Server
SELECT *
  FROM Project2..NashvilleHousingdata

  --Standardize date format
  Select SaleDateConverted ,Convert(Date,SaleDate) as sale_date
   FROM Project2..NashvilleHousingdata
  
  ALTER Table Project2.dbo.NashvilleHousingdata
  Add SaleDateConverted Date;

  Update Project2.dbo.NashvilleHousingdata
  Set SaleDateConverted=Convert(Date,SaleDate)

  --Populate propertyaddress data
  SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress ,ISNULL(a.PropertyAddress,b.PropertyAddress) as populatedpropertyaddress
  FROM Project2..NashvilleHousingdata a
  JOIN Project2..NashvilleHousingdata b
  on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
  Where a.PropertyAddress is null

  Update a 
  SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
  FROM Project2..NashvilleHousingdata a
  JOIN Project2..NashvilleHousingdata b
  on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
  Where a.PropertyAddress is null


  --PARSING DATA INTO SEPARATE COLUMNS (ADDRESS,CITY,STATE)

  Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
   FROM Project2..NashvilleHousingdata

   ALTER Table Project2..NashvilleHousingdata
   Add Propertysplitaddress nvarchar(255);

   Update Project2..NashvilleHousingdata
   Set Propertysplitaddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

   
   ALTER Table Project2..NashvilleHousingdata
   Add Propertysplitcity nvarchar(255);

   Update Project2..NashvilleHousingdata
   Set Propertysplitcity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

   SELECT *
  FROM Project2..NashvilleHousingdata

  --For owner address
  Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
   PARSENAME(REPLACE(OwnerAddress,',','.'),2),
    PARSENAME(REPLACE(OwnerAddress,',','.'),1)
  FROM Project2..NashvilleHousingdata

  ALTER Table Project2..NashvilleHousingdata
  add ownersplitaddress nvarchar(255);

  Update Project2..NashvilleHousingdata
  set ownersplitaddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

   ALTER Table Project2..NashvilleHousingdata
  add ownersplitcity nvarchar(255);

  Update Project2..NashvilleHousingdata
  set ownersplitcity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

   ALTER Table Project2..NashvilleHousingdata
  add ownersplitstate nvarchar(255);

  Update Project2..NashvilleHousingdata
  set ownersplitstate= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


  --Changing different types of Yes and No to one representation

  Select soldasvacant,COUNT(soldasvacant)
  From Project2..NashvilleHousingdata
  Group by soldasvacant
  Order by 2

  Select soldasvacant,
  CASE When soldasvacant='N' Then 'No'
	   When soldasvacant='Y' Then 'Yes'
	   Else soldasvacant
	   End
From Project2..NashvilleHousingdata
 

 Update  Project2..NashvilleHousingdata
 Set SoldAsVacant=CASE When soldasvacant='N' Then 'No'
	   When soldasvacant='Y' Then 'Yes'
	   Else soldasvacant
	   End


---Remove duplicates
With RowNumCTE as
	(Select *,ROW_NUMBER() Over (Partition by ParcelId,PropertyAddress,SaleDate,SalePrice,LegalReference Order by UniqueId) as row_num
		From Project2..NashvilleHousingdata)
Delete From RowNumCTE
Where row_num>1


--Delete Unused columns

ALTER Table Project2..NashvilleHousingdata
DROP Column OwnerAddress,PropertyAddress,TaxDistrict,SaleDate


 SELECT *
  FROM Project2..NashvilleHousingdata
