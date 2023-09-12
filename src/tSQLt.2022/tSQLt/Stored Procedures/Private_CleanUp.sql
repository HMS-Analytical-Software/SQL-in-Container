﻿CREATE PROCEDURE tSQLt.Private_CleanUp
  @FullTestName NVARCHAR(MAX),
  @Result NVARCHAR(MAX) OUTPUT,
  @ErrorMsg NVARCHAR(MAX) OUTPUT
AS
BEGIN

  EXEC tSQLt.Private_CleanUpCmdHandler 
         @CleanUpCmd = 'EXEC tSQLt.Private_NoTransactionHandleTables @Action=''Reset'';',
         @TestResult = @Result OUT,
         @TestMsg = @ErrorMsg OUT,
         @ResultInCaseOfError = 'FATAL';

  EXEC tSQLt.Private_CleanUpCmdHandler 
         @CleanUpCmd = 'EXEC tSQLt.UndoTestDoubles @Force = 0;',
         @TestResult = @Result OUT,
         @TestMsg = @ErrorMsg OUT,
         @ResultInCaseOfError = 'Abort';

END;