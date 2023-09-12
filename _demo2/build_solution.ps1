$startTime = Get-Date

Write-Host "Building SQL projects..." -ForegroundColor Yellow
dotnet build ..\src\Northwind.sln /p:NetCoreBuild=true --configuration Release

$endTime = Get-Date
$elapsedTime = $endTime - $startTime
Write-Host "Done: SQL projects in $($elapsedTime.TotalSeconds) sec." -ForegroundColor Blue


Write-Host "Preparing podman build environment..." -ForegroundColor Yellow
Rename-Item .\src .\_src
New-Item -Path .\src -ItemType Directory

Copy-Item -Path ..\src\Northwind.Tests\bin\Release\* .\src
Copy-Item -Path ..\_demo1\instnwnd.sql .\src
Copy-Item -Path  ..\src\Externals\tSQLt.PrepareServer.sql .\src

Write-Host "Done: podman build environment created" -ForegroundColor Blue

$startTime = Get-Date
Write-Host "Building Podman image..." -ForegroundColor Yellow
&podman build --tag devdb:latest .
$endTime = Get-Date
$elapsedTime = $endTime - $startTime
Write-Host "Done: Podman image creation in $($elapsedTime.TotalSeconds) sec." -ForegroundColor Blue


$startTime = Get-Date
Write-Host "Start Database Dev Container..." -ForegroundColor Yellow
&podman run -d -p 1733:1433 --hostname hisdevenv devdb:latest
$endTime = Get-Date
$elapsedTime = $endTime - $startTime
Write-Host "Done: Database Dev Container is startd in $($elapsedTime.TotalSeconds) sec." -ForegroundColor Blue

Start-Sleep -Seconds 20

$startTime = Get-Date
Write-Host "Run tSQLt tests..." -ForegroundColor Yellow
&sqlcmd -S 127.0.0.1,1733 -U sa -P dev_sa1337! -d Northwind -y0 -Q "EXEC tSQLt.SetTestResultFormatter @Formatter = NULL;EXEC tSQLt.RunAll" 
&sqlcmd -S 127.0.0.1,1733 -U sa -P dev_sa1337! -d Northwind -y0 -Q "SET NOCOUNT ON; EXEC tSQLt.SetTestResultFormatter @Formatter = 'tSQLt.XmlResultFormatter';EXEC tSQLt.RunAll " -o testresults.xml
$endTime = Get-Date
$elapsedTime = $endTime - $startTime
Write-Host "Done: tSQLt tests are executed in $($elapsedTime.TotalSeconds) sec." -ForegroundColor Blue