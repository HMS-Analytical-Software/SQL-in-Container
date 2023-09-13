﻿CREATE PROCEDURE tSQLt.Private_NoTransactionHandleTables
  @Action NVARCHAR(MAX)
AS
BEGIN
  DECLARE @cmd NVARCHAR(MAX) = (
    SELECT 'EXEC tSQLt.Private_NoTransactionHandleTable @Action = '''+@Action+''', @FullTableName = '''+X.Name+''', @TableAction = '''+X.Action+''';'
      FROM tSQLt.Private_NoTransactionTableAction X
     WHERE X.Action <> 'Ignore'
       FOR XML PATH(''),TYPE
  ).value('.','NVARCHAR(MAX)');
  EXEC(@cmd);
END;