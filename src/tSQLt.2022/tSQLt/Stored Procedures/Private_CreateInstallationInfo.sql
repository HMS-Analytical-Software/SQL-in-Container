﻿CREATE PROCEDURE tSQLt.Private_CreateInstallationInfo 
-- Created as a stored procedure to make it testable.
AS
BEGIN
  DECLARE @cmd NVARCHAR(MAX);
  SELECT 
      @cmd = 'ALTER FUNCTION tSQLt.Private_InstallationInfo() RETURNS TABLE AS RETURN SELECT CAST('+
             CAST(I.SqlVersion AS NVARCHAR(MAX))+
             ' AS NUMERIC(10,2)) AS SqlVersion;'
    FROM tSQLt.Info() AS I;

  EXEC(@cmd);
END;