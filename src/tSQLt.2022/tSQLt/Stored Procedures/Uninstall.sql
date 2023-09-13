﻿CREATE PROCEDURE tSQLt.Uninstall
AS
BEGIN

  EXEC tSQLt.DropClass @ClassName = 'tSQLt';  
  
  IF(EXISTS(SELECT 1 FROM sys.assemblies WHERE name = 'tSQLtCLR'))DROP ASSEMBLY tSQLtCLR;

  IF USER_ID('tSQLt.TestClass') IS NOT NULL DROP USER [tSQLt.TestClass];

END;