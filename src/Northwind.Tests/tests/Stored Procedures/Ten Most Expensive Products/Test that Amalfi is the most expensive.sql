CREATE PROCEDURE [Tests].[Test that Amalfi is the most expensive]
AS
BEGIN
	insert into dbo.Products (ProductName, UnitPrice) values ('D''Amalfi Limoncello Supreme', 44000000)
    
	DECLARE @tblVar TABLE (
		ProductName NVARCHAR(40),
		UnitPrice money
	)
	INSERT INTO @tblVar exec [dbo].[Ten Most Expensive Products] 
	
	DECLARE @mostexpensive nvarchar(40)
	select top 1 @mostexpensive = ProductName from @tblVar

	EXEC tSQLt.AssertEquals 'D''Amalfi Limoncello Supreme', @mostexpensive;
END;
