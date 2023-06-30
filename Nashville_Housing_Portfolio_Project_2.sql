--Nashville Housing Data Cleaning Project
/*
Note: some variables will be underlined with a red line, this is because these variables or columns had been deleted
in the last part of this project 
*/

select *
from NHousing

---------------------------------------------------------------------------------------------
--adding a new table named saledateEdited
alter table nhousing
add saledateEdited date;

--adding the content of saledate to saledateedited after converting it to date type(was date time previously)
update nhousing
set saledateEdited = convert(date,saledate)

select saledateEdited 
from NHousing

---------------------------------------------------------------------------------------------
--populating property address data
select NH1.ParcelID,NH1.PropertyAddress,NH2.ParcelID,NH2.PropertyAddress,
isnull(NH1.propertyaddress,NH2.PropertyAddress) 
from NHousing NH1
JOIN NHousing NH2	
on NH1.[UniqueID ]<>NH2.[UniqueID ]
and NH1.ParcelID=NH2.ParcelID
where NH1.PropertyAddress is null 

update NH1
set PropertyAddress =
isnull(NH1.propertyaddress,NH2.PropertyAddress) 
from NHousing NH1
JOIN NHousing NH2	
on NH1.[UniqueID ]<>NH2.[UniqueID ]
and NH1.ParcelID=NH2.ParcelID
where NH1.PropertyAddress is null 

---------------------------------------------------------------------------------------------

--breaking property address into two different columns(address,city)
select propertyaddress
from NHousing

/*
I took the data from the beginning of propertyaddress until the comma and placed it in a column named PropertySplitAddress,
and took the data from after the comma and placed it in a column named PropertySplitCity
*/
select
substring(propertyaddress,1,charindex(',',propertyaddress)-1) address,
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) state
from nhousing

alter table nhousing
add PropertySplitAddress nvarchar(255),
PropertySplitCity  nvarchar(255)

update nhousing
set propertysplitaddress = substring(propertyaddress,1,charindex(',',propertyaddress)-1)

update nhousing
set propertySplitCity = substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) 


---------------------------------------------------------------------------------------------

--splitting OwnerAddress into three columns (address,city,state) by using parsename

select owneraddress,
parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from nhousing
where owneraddress is not null

alter table nhousing 
add OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

update nhousing
set OwnerSplitAddress = parsename(replace(owneraddress,',','.'),3),
	OwnerSplitCity = parsename(replace(owneraddress,',','.'),2),
	OwnerSplitState = parsename(replace(owneraddress,',','.'),1)

---------------------------------------------------------------------------------------------
--change Y and N into Yes and No in the column SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'N' then 'No'
	 when soldasvacant = 'Y' then 'Yes'
	 else soldasvacant
	 end
from NHousing

update NHousing
set SoldAsVacant = 
case when SoldAsVacant = 'N' then 'No'
	 when soldasvacant = 'Y' then 'Yes'
	 else soldasvacant
	 end

---------------------------------------------------------------------------------------------
--removing duplicates
with RowNumCTE as(
select *,ROW_NUMBER	() over (
partition by parcelid, propertyaddress,saledate,saleprice,legalreference
order by uniqueid)row_num
from nhousing
)

delete
from RowNumCTE
where row_num > 1

---------------------------------------------------------------------------------------------
--deleting unwanted columns
alter table nhousing
drop column owneraddress,taxdistrict,propertyaddress,saledate 
