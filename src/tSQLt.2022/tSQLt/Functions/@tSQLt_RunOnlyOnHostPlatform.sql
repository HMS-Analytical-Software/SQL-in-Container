﻿CREATE FUNCTION tSQLt.[@tSQLt:RunOnlyOnHostPlatform](@HostPlatform NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN
  SELECT SkipTestFunction.*
    FROM (SELECT I.HostPlatform FROM tSQLt.Info() AS I WHERE I.HostPlatform <> @HostPlatform) AV
   CROSS APPLY tSQLt.[@tSQLt:SkipTest]('HostPlatform is required to be '''+
                                       @HostPlatform +
                                       ''', but is '''+
                                       AV.HostPlatform +
                                       '''.'
                                      ) AS SkipTestFunction;