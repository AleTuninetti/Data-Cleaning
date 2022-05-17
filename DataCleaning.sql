/*
Data Cleaning in SQL Queries

*/
Select * from PortfolioProject..NashvilleHousing

---------------------------
-- Standarize Data FORMAT (voy a quitar las hs del formato del día, cambio de datetime a DATE)

Select SaleDate, convert (date, SaleDate) from PortfolioProject..NashvilleHousing

update NashvilleHousing
set Saledate = convert(date, saledate)
--esta conversión anterior NO resultó, entonces agregaremos una columna con el formato que queremos

alter table NashvilleHousing
add SaleDateConverted Date

--le voy los valores a columa nueva
update NashvilleHousing
set SaleDateConverted = convert(date, saledate)

--pruebo nuevamente si ahora tengo datos en formato y columna nueva

Select SaleDate, SaleDateConverted from PortfolioProject..NashvilleHousing

------------------------------------------------------------
-- Populate Property Address Data

--Busco valores donde el campo dirección (address) esté vacío
Select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

--voy a buscar repetidos (donde coinciden ParcelID+PropertyAddress), para luego ver si es necesario eliminarlos. Hago SelfJoin
--para busqueda iguales
Select *
from PortfolioProject..NashvilleHousing AS A
join PortfolioProject..NashvilleHousing AS B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
--AND a.PropertyAddress is null
--order by a.ParcelID

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
from PortfolioProject..NashvilleHousing AS A
join PortfolioProject..NashvilleHousing AS B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null
--order by a.ParcelID

--compruebo un dato q tenga solo una direccón cargada, aunque sean iguales
Select *
from PortfolioProject..NashvilleHousing
where ParcelID= '025 07 0 031.00'

--ahora agrego columna con la info que tengo en el adress repetido que si tiene el dato
Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, 
ISNULL (a.PropertyAddress, b.PropertyAddress) As ValorACopiar
from PortfolioProject..NashvilleHousing AS A
join PortfolioProject..NashvilleHousing AS B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
--Where a.PropertyAddress is null

--vuelvo a probar query anterior, NO debería tener valores NULL (me sigue trayendo null xq en paso anterior NO modifiqué columna)
Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
--if a.PropertyAddress is null then a.PropertyAddress = b.PropertyAddress
from PortfolioProject..NashvilleHousing AS A
join PortfolioProject..NashvilleHousing AS B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null

--para modificar columna (carga valores de otra columna)
UPDATE A
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing AS A
join PortfolioProject..NashvilleHousing AS B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null

--vuelvo a probar query anterior, ahora NO debería tener valores NULL
Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
from PortfolioProject..NashvilleHousing AS A
join PortfolioProject..NashvilleHousing AS B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
--Where a.PropertyAddress is null

-----------------------------------------------------------------------
--Breaking out Adress into individual columns (Adress, City, State)

select 
* from nashvillehousing
--where PropertyAddress is null

--para "cortar" texto (como separador de: ,/ ;/ "espacio" de Excel)// Charindex busca el caracter que le pido, en la columna especificada
Select
SUBSTRING (PropertyAddress,1 , CHARINDEX(',',PropertyAddress)) As Adress
from NashvilleHousing

--para "mostrar" el texto separado, pero sin la coma "," (como separador de: ,/ ;/ "espacio" de Excel)
Select
SUBSTRING (PropertyAddress,1 , CHARINDEX(',',PropertyAddress)-1) As Adress
from NashvilleHousing

--para ver el texto completo, pero los campos separados (como separador de: ,/ ;/ "espacio" de Excel)
Select PropertyAddress, SUBSTRING (PropertyAddress,1 , CHARINDEX(',',PropertyAddress)-1) As Adress, 
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) As State
from NashvilleHousing


--en el punto anterior NO creé columnas separadas, lo haré ahora 
ALTER TABLE NashvilleHousing
ADD
Adress nvarchar (255),
State nvarchar (255)


UPDATE NashvilleHousing
SET
Address = SUBSTRING (PropertyAddress,1 , CHARINDEX(',',PropertyAddress)-1) , 
State =SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 
from NashvilleHousing

--verifico la creación correcta, miro sólo las primeras 10 posiciones
SELECT TOP (10) PropertyAddress
      ,[Address]
      ,[State]
FROM [PortfolioProject].[dbo].[NashvilleHousing]

select top (10) * from NashvilleHousing

 --alternativa facil para hacer SPlit de texto, PARSENAME
 --lo haremos para Owner
Select OwnerAddress from NashvilleHousing

-- como PARSENAME funciona para períodos, trae la fila sin cambios
Select OwnerAddress,
PARSENAME (OwnerAddress, 1) from NashvilleHousing

-- PARSENAME: cambiamos (,) por punto (.). Trae texto de izquierda a derecha según encuentra el punto? cantidad posiciones = 2do parámetro
Select OwnerAddress,
PARSENAME (REPLACE (OwnerAddress, ',', '.'),1),
PARSENAME (REPLACE (OwnerAddress, ',', '.'),2),
PARSENAME (REPLACE (OwnerAddress, ',', '.'),3)
from NashvilleHousing
where OwnerAddress is not null

--ordeno para q quede de la misma manera q OwnerAddress
Select OwnerAddress,
PARSENAME (REPLACE (OwnerAddress, ',', '.'),3),
PARSENAME (REPLACE (OwnerAddress, ',', '.'),2),
PARSENAME (REPLACE (OwnerAddress, ',', '.'),1)
from NashvilleHousing
where OwnerAddress is not null

--creo las columnas para dividir en los 3 campos
ALTER TABLE NashvilleHousing
ADD
OwnerAddres nvarchar (255),
OwnerCity nvarchar (255),
OwnerState nvarchar (255)

--agrego los datos
UPDATE NashvilleHousing
SET
OwnerAddress2 = PARSENAME (REPLACE (OwnerAddress, ',', '.'),3),
OwnerCity = PARSENAME (REPLACE (OwnerAddress, ',', '.'),2),
OwnerState = PARSENAME (REPLACE (OwnerAddress, ',', '.'),1)

Select OwnerAddress,
OwnerAddress2, OwnerCity, OwnerState
from NashvilleHousing
where OwnerAddress is not null

------------------------------------------------------------
-- SoldAsVacant , change words (N -> No, Y -> Yes)
-- Reviso distintas palabras con que se carga la columna y luego la cantidad de cada uno
Select distinct (SoldAsVacant)
from NashvilleHousing

-- Reviso la cantidad de cada una de las palabras (o filas que la contienen)
Select SoldAsVacant, count (SoldAsVacant) --, distinct (SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant

-- Pruebo los cambios necesarios para unificar el contenido en  YES/NO
Select SoldAsVacant,
	case 
		WHEN SoldAsVacant = 'N' then 'No'
		WHEN SoldAsVacant = 'Y' then 'Yes'
		ELSE SoldAsVacant
	end
from NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant


-- Aplico los cambios en la columna
UPDATE NashvilleHousing
SET SoldAsVacant =
					case 
						WHEN SoldAsVacant = 'N' then 'No'
						WHEN SoldAsVacant = 'Y' then 'Yes'
						ELSE SoldAsVacant
					end
from NashvilleHousing
--group by SoldAsVacant
--order by SoldAsVacant

--reviso que se haya modificado
Select distinct (SoldAsVacant)
from NashvilleHousing

--------------------------------------------------------------------------
--Remove Duplicates
--1ro busco info que pueda estar duplicada

Select distinct *
from NashvilleHousing

Select * /*a.[UniqueID ], a.ParcelID, a.PropertyAddress, a.SaleDate, a.LegalReference,
		b.[UniqueID ],b.ParcelID, b.PropertyAddress, b.SaleDate, b.LegalReference*/
from PortfolioProject..NashvilleHousing AS A
join PortfolioProject..NashvilleHousing AS B
	ON a.ParcelID = b.ParcelID
	AND a.PropertyAddress = b.PropertyAddress 
	AND a.SaleDate = b.SaleDate
	AND a.SalePrice = b.SalePrice
	AND a.LegalReference = b.LegalReference
	AND a.[UniqueID ] <> b.[UniqueID ]
order by a.ParcelID
/*The Row_Number function is used to provide consecutive numbering of the rows in the result by the order selected in the OVER clause for 
each partition specified in the OVER clause. It will assign the value 1 for the first row and increase the number of the subsequent rows*/
-- Busco duplicados en los campos (deben coincidir: parcel, address, Sale, etc), el row number va a dar distintos de 1 cdo encuentre
Select *,ROW_NUMBER ()
over (
	Partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
	order by ParcelID
	) AS row_num
from NashvilleHousing
order by ParcelID
--where row_num >1

-- como row number es un calculo nuevo, NO puedo hacer where acá --> hago CTE para calcular y luego agregaré el WHERE
-- para ver si cumplo condicion de duplicados

WITH CTEduplicados AS
(
	Select *,ROW_NUMBER ()
		over (
			Partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
			order by ParcelID
			) AS row_num
		from NashvilleHousing
 )

Select * from CTEduplicados
where row_num >1

-- Borro los duplicados
DELETE from CTEduplicados
where row_num >1

--------------------------------------------------------------------------
--Delete Unused Columns

select * from NashvilleHousing

ALTER TABLE NashvilleHousing
Drop Column TaxDistrict
