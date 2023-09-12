 param (
    [string]$server = "127.0.0.1,1433",
    [string]$username = "sa",
    [string]$password = "dev_sa1337!",
    [string]$database = "Northwind" 
 )

# dotnet tool install -g microsoft.sqlpackage
dotnet build Northwind.sln /p:NetCoreBuild=true
sqlpackage /Action:Publish /TargetConnectionString:"Server=$server;Database=$database;User Id=$username;Password=$password;TrustServerCertificate=true" /SourceFile:"./Northwind.Tests/bin/debug/Northwind.Tests.dacpac" /Profile:"./Northwind.Tests/Northwind.Tests.publish.xml"
sqlcmd -S $server -U $username -P $password -d $database -y0 -Q "SET NOCOUNT ON;EXEC tSQLt.RunAll"
