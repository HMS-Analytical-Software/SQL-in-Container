# Prepare Podman
&podman machine init
&podman machine start



# DEMO 1 - Prototyping:
&podman run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=yourStrong(!)Password" -e "MSSQL_PID=Evaluation" -p 1633:1433  --name sqlpassdemo1 -d -v C:\Projekte\his\SQLPassVortrag\demo1\dbserver:/var/opt/mssql/data -v C:\Projekte\his\SQLPassVortrag\demo1\transfer:/transfer mcr.microsoft.com/mssql/server:2022-preview-ubuntu-22.04

<# Konfigurationsparameter für Connection
HOST: 127.0.0.1,1633
USER: sa
PASSWORD: yourStrong(!)Password

#>

<# Restore Datenbank
USE [master]
RESTORE DATABASE [AdventureWorks2022] FROM  DISK = N'/transfer/AdventureWorks2022.bak' WITH  FILE = 1,  MOVE N'AdventureWorks2022' TO N'/var/opt/mssql/data/AdventureWorks2022.mdf',  MOVE N'AdventureWorks2022_log' TO N'/var/opt/mssql/data/AdventureWorks2022_log.ldf',  NOUNLOAD,  STATS = 5
GO

#>

<# Ausführung von instnwnd.sql

#>

<# Beispiel Code
USE AdventureWorks2022

SELECT ROW_NUMBER() OVER (PARTITION BY PostalCode ORDER BY SalesYTD DESC) AS "Row Number",
p.LastName, s.SalesYTD, a.PostalCode
FROM Sales.SalesPerson AS s
    INNER JOIN Person.Person AS p
        ON s.BusinessEntityID = p.BusinessEntityID
    INNER JOIN Person.Address AS a
        ON a.AddressID = p.BusinessEntityID
WHERE TerritoryID IS NOT NULL
    AND SalesYTD <> 0
ORDER BY PostalCode;
GO


SELECT *
FROM GENERATE_SERIES(1, 10);

SELECT DATEADD(DAY,value,'2022-01-01')
FROM GENERATE_SERIES(0,364,1);

#>