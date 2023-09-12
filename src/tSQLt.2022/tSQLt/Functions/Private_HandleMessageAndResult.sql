﻿CREATE FUNCTION tSQLt.Private_HandleMessageAndResult (
  @PrevMessage NVARCHAR(MAX),
  @PrevResult NVARCHAR(MAX),
  @NewMessage NVARCHAR(MAX),
  @NewResult NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
  SELECT CASE WHEN ISNULL(@PrevMessage,'') NOT LIKE '%[^ '+CHAR(9)+']%' AND @PrevResult = 'Success' THEN '' 
              ELSE CASE WHEN @PrevMessage NOT LIKE '%[^ '+CHAR(9)+']%' THEN '<empty>' ELSE ISNULL(@PrevMessage,'<NULL>') END+' [Result: '+
                   CASE WHEN @PrevResult NOT LIKE '%[^ '+CHAR(9)+']%' THEN '<empty>' ELSE ISNULL(@PrevResult,'<NULL>') END+'] || ' 
         END+
         CASE WHEN @NewMessage NOT LIKE '%[^ '+CHAR(9)+']%' THEN '<empty>' ELSE ISNULL(@NewMessage,'<NULL>') END Message,
         (SELECT TOP(1) Result FROM tSQLt.Private_Results WHERE Result IN (@PrevResult, @NewResult) ORDER BY Severity DESC) Result;