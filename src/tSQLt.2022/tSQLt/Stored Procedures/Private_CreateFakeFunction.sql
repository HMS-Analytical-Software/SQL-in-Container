﻿CREATE PROCEDURE tSQLt.Private_CreateFakeFunction
  @FunctionName         NVARCHAR(MAX),
  @FakeFunctionName     NVARCHAR(MAX) = NULL,
  @FunctionObjectId     INT = NULL,
  @FakeFunctionObjectId INT = NULL,
  @IsScalarFunction     BIT = NULL,
  @FakeDataSource       NVARCHAR(MAX) = NULL 
AS
BEGIN
  DECLARE @ReturnType NVARCHAR(MAX);
  SELECT @ReturnType = T.TypeName
    FROM sys.parameters AS P
   CROSS APPLY tSQLt.Private_GetFullTypeName(P.user_type_id,P.max_length,P.precision,P.scale,NULL) AS T
   WHERE P.object_id = @FunctionObjectId
     AND P.parameter_id = 0;
     
  DECLARE @ParameterList NVARCHAR(MAX);
  SELECT @ParameterList = COALESCE(
     STUFF((SELECT ','+P.name+' '+T.TypeName+CASE WHEN T.IsTableType = 1 THEN ' READONLY' ELSE '' END
              FROM sys.parameters AS P
             CROSS APPLY tSQLt.Private_GetFullTypeName(P.user_type_id,P.max_length,P.precision,P.scale,NULL) AS T
             WHERE P.object_id = @FunctionObjectId
               AND P.parameter_id > 0
             ORDER BY P.parameter_id
               FOR XML PATH(''),TYPE
           ).value('.','NVARCHAR(MAX)'),1,1,''),'');
           
  DECLARE @ParameterCallList NVARCHAR(MAX);
  SELECT @ParameterCallList = COALESCE(
     STUFF((SELECT ','+P.name
              FROM sys.parameters AS P
             CROSS APPLY tSQLt.Private_GetFullTypeName(P.user_type_id,P.max_length,P.precision,P.scale,NULL) AS T
             WHERE P.object_id = @FunctionObjectId
               AND P.parameter_id > 0
             ORDER BY P.parameter_id
               FOR XML PATH(''),TYPE
           ).value('.','NVARCHAR(MAX)'),1,1,''),'');


  IF(@IsScalarFunction = 1)
  BEGIN
    EXEC('CREATE FUNCTION '+@FunctionName+'('+@ParameterList+') RETURNS '+@ReturnType+' AS BEGIN RETURN '+@FakeFunctionName+'('+@ParameterCallList+');END;'); 
  END
  ELSE 
  BEGIN
    DECLARE @cmd NVARCHAR(MAX);
    IF (@FakeDataSource IS NOT NULL)
    BEGIN
       SET @cmd = 
        CASE 
          WHEN OBJECT_ID(@FakeDataSource) IS NOT NULL THEN 'SELECT * FROM '+@FakeDataSource
          WHEN @FakeDataSource LIKE '(%)%(%)' THEN 'SELECT * FROM '+@FakeDataSource
          ELSE @FakeDataSource
        END;
    END
    ELSE
    BEGIN
      SET @cmd = 'SELECT * FROM '+@FakeFunctionName+'('+@ParameterCallList+')'; 
    END;
    SET @cmd = 'CREATE FUNCTION '+@FunctionName+'('+@ParameterList+') RETURNS TABLE AS RETURN '+@cmd+';'
    EXEC(@cmd);
  END;
END;