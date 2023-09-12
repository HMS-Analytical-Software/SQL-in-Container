CREATE PROCEDURE [Tests].[Test that exactly 10 records are returned]
AS
BEGIN
	DECLARE @tblVar TABLE (
		ProductName NVARCHAR(40),
		UnitPrice money
	)
	INSERT INTO @tblVar exec [dbo].[Ten Most Expensive Products] 
	
	DECLARE @rows int
	select @rows = count(*) from @tblVar

	EXEC tSQLt.AssertEquals 10, @rows;
END;

