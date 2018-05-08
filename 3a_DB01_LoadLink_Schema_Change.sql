/*
DataTeam
LoadLink Partitioning

DBA:
-Monitor Transaction Logs and Blocking throughout process

•	DROP FK w/if exist
•	DROP PK w/if exist (Result Heap on all table in set)
•	ADD Partition Column and Back Fill Data
•	ALTER NULL Column and ADD DF 
•	ADD Clustered
•	ADD PK
•	ADD UX
•	ADD FK
•	Update Stats
	(The final state will be verified in a different step)

Run in DB01VPRD Equivilant 
*/
USE LoadLink
GO

--===================================================================================================
--[START]
--===================================================================================================
PRINT '********************';
PRINT '!!! Script START !!!';
PRINT '********************';

IF ( SELECT @@SERVERNAME ) = 'DB01VPRD' BEGIN PRINT 'Running in Environment DB01VPRD...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'QA4-DB01' BEGIN PRINT 'Running in Environment QA4-DB01...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01' BEGIN PRINT 'Running in Environment DATATEAM4-DB01\DB01...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;


--===================================================================================================
--[REMOVE FK]
--===================================================================================================
PRINT '*****************';
PRINT '*** Remove FK ***';
PRINT '*****************';


--************************************************
PRINT 'Working on table [dbo].[BatchProcessingLog] ...'; 

IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_BatchProcessingLog_ActivityTypeLookup'
                AND  parent_object_id = OBJECT_ID( N'dbo.BatchProcessingLog' ))
BEGIN
    ALTER TABLE dbo.BatchProcessingLog DROP CONSTRAINT FK_BatchProcessingLog_ActivityTypeLookup;
    PRINT '- FK [FK_BatchProcessingLog_ActivityTypeLookup] Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_BatchProcessingLog_ActivityTypeLookup_ActivityTypeID'
                     AND  parent_object_id = OBJECT_ID( N'dbo.BatchProcessingLog' ))
	BEGIN
	    ALTER TABLE dbo.BatchProcessingLog DROP CONSTRAINT FK_BatchProcessingLog_ActivityTypeLookup_ActivityTypeID;
	    PRINT '- FK [FK_BatchProcessingLog_ActivityTypeLookup_ActivityTypeID] Dropped';
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO

IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_BatchProcessingLog_BatchQueue'
                AND  parent_object_id = OBJECT_ID( N'dbo.BatchProcessingLog' ))
BEGIN
    ALTER TABLE dbo.BatchProcessingLog DROP CONSTRAINT FK_BatchProcessingLog_BatchQueue;
    PRINT '- FK [FK_BatchProcessingLog_BatchQueue] Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_BatchProcessingLog_BatchQueue_BatchId'
                     AND  parent_object_id = OBJECT_ID( N'dbo.BatchProcessingLog' ))
	BEGIN
	    ALTER TABLE dbo.BatchProcessingLog DROP CONSTRAINT FK_BatchProcessingLog_BatchQueue_BatchId;
	    PRINT '- FK [FK_BatchProcessingLog_BatchQueue_BatchId] Dropped';
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO

PRINT 'Working on table [dbo].[dbo.ShipmentQueue ] ...'; 

IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_ShipmentQueue_BatchQueue'
                AND  parent_object_id = OBJECT_ID( N'dbo.ShipmentQueue' ))
BEGIN
    ALTER TABLE dbo.ShipmentQueue DROP CONSTRAINT FK_ShipmentQueue_BatchQueue;
    PRINT '- FK [FK_ShipmentQueue_BatchQueue] Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_ShipmentQueue_BatchQueue_BatchId'
                     AND  parent_object_id = OBJECT_ID( N'dbo.ShipmentQueue' ))
	BEGIN
	    ALTER TABLE dbo.ShipmentQueue DROP CONSTRAINT FK_ShipmentQueue_BatchQueue_BatchId;
	    PRINT '- FK [FK_ShipmentQueue_BatchQueue_BatchId] Dropped';
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO

IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_ShipmentQueue_TransactionType'
                AND  parent_object_id = OBJECT_ID( N'dbo.ShipmentQueue' ))
BEGIN
    ALTER TABLE dbo.ShipmentQueue DROP CONSTRAINT FK_ShipmentQueue_TransactionType;
    PRINT '- FK [FK_ShipmentQueue_TransactionType] Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_ShipmentQueue_TransactionTypeLookup_TypeID'
                     AND  parent_object_id = OBJECT_ID( N'dbo.ShipmentQueue' ))
	BEGIN
	    ALTER TABLE dbo.ShipmentQueue DROP CONSTRAINT FK_ShipmentQueue_TransactionTypeLookup_TypeID;
	    PRINT '- FK [FK_ShipmentQueue_TransactionTypeLookup_TypeID] Dropped';
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO


--===================================================================================================
--[REMOVE ALL PKs]
--===================================================================================================
PRINT '***************************';
PRINT '*** Remove PK/Clustered ***';
PRINT '***************************';

--************************************************
PRINT 'Working on table [dbo].[BatchProcessingLog] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'dbo.BatchProcessingLog' )
				AND  name = N'PK_BatchProcessingLog'
          )
BEGIN    
	ALTER TABLE dbo.BatchProcessingLog DROP CONSTRAINT PK_BatchProcessingLog;
    PRINT '- PK [PK_BatchProcessingLog] Dropped';
END;

PRINT 'Working on table [dbo].[ShipmentQueue] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'dbo.ShipmentQueue' )
				AND  name = N'PK_ShipmentQueue'
          )
BEGIN    
	ALTER TABLE dbo.ShipmentQueue DROP CONSTRAINT PK_ShipmentQueue;
    PRINT '- PK [PK_ShipmentQueue] Dropped';
END;


--===================================================================================================
--[ADD PARTITION COLUMNs]
--===================================================================================================
--PRINT '*****************************';
--PRINT '*** Add Partition Columns ***';
--PRINT '*****************************';

--===================================================================================================
--[BACK FILL DATA]
--===================================================================================================
--PRINT '**********************';
--PRINT '*** Back Fill Data ***';
--PRINT '**********************';

--===================================================================================================
--[ALTER NULL COLUMN AND ADD DF]
--===================================================================================================
--PRINT '************************************';
--PRINT '*** Alter NULL Column And Add DF ***';
--PRINT '************************************';

--===================================================================================================
--[CREATE CLUSTERED INDEX]
--===================================================================================================
PRINT '******************************';
PRINT '*** Create Clustered Index ***';
PRINT '******************************';

--************************************************
PRINT 'Working on table [dbo].[BatchProcessingLog] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_BatchProcessingLog_LogDate ' )
BEGIN
    DROP INDEX CIX_BatchProcessingLog_LogDate  ON dbo.BatchProcessingLog;
	PRINT '- Index [CIX_BatchProcessingLog_LogDate ] Dropped';
END;

CREATE CLUSTERED INDEX CIX_BatchProcessingLog_LogDate 
ON dbo.BatchProcessingLog ( LogDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_LoadLink_DATETIME_1Year (LogDate);
PRINT '- Index [CIX_BatchProcessingLog_LogDate ] Created';

PRINT 'Working on table [dbo].[ShipmentQueue] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_ShipmentQueue_Completed  ' )
BEGIN
    DROP INDEX CIX_ShipmentQueue_Completed   ON dbo.ShipmentQueue;
	PRINT '- Index [CIX_BatchProcessingLog_LogDate ] Dropped';
END;

CREATE CLUSTERED INDEX CIX_ShipmentQueue_Completed  
ON dbo.ShipmentQueue ( Completed ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_LoadLink_DATETIME_1Year (Completed);
PRINT '- Index [CIX_ShipmentQueue_Completed  ] Created';



--===================================================================================================
--[CREATE PKs]
--===================================================================================================
PRINT '******************';
PRINT '*** Create PKs ***';
PRINT '******************';

--************************************************
PRINT 'Working on table [dbo].[BatchProcessingLog] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_BatchProcessingLog_ID_LogDate' )
BEGIN
    ALTER TABLE dbo.BatchProcessingLog DROP CONSTRAINT PK_BatchProcessingLog_ID_LogDate;
	PRINT '- PK [PK_BatchProcessingLog_ID_LogDate] Dropped';
END;

ALTER TABLE dbo.BatchProcessingLog
ADD CONSTRAINT PK_BatchProcessingLog_ID_LogDate
    PRIMARY KEY NONCLUSTERED ( ID, LogDate)
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_LoadLink_DATETIME_1Year(LogDate);
PRINT '- PK [PK_BatchProcessingLog_ID_LogDate] Created';

PRINT 'Working on table [dbo].[ShipmentQueue] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_ShipmentQueue_ID_Completed' )
BEGIN
    ALTER TABLE dbo.ShipmentQueue DROP CONSTRAINT PK_ShipmentQueue_ID_Completed;
	PRINT '- PK [PK_ShipmentQueue_ID_Completed] Dropped';
END;

ALTER TABLE dbo.ShipmentQueue
ADD CONSTRAINT PK_ShipmentQueue_ID_Completed
    PRIMARY KEY NONCLUSTERED ( ID, Completed)
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_LoadLink_DATETIME_1Year(Completed);
PRINT '- PK [PK_tableName_originalPrimaryKeyColumnName_columnName] Created';


--===================================================================================================
--[CREATE UX]
--===================================================================================================
--PRINT '***************************';
--PRINT '*** Create Unique Index ***';
--PRINT '***************************';

--===================================================================================================
--[CREATE FK]
--===================================================================================================
PRINT '*****************';
PRINT '*** Create FK ***';
PRINT '*****************';

--*****************************************************
PRINT 'Working on table [dbo].[BatchProcessingLog] ...';

ALTER TABLE dbo.BatchProcessingLog WITH NOCHECK
ADD CONSTRAINT FK_BatchProcessingLog_ActivityTypeLookup_ActivityTypeID
    FOREIGN KEY ( ActivityTypeId )
    REFERENCES dbo.ActivityTypeLookup ( ActivityTypeID ) 
	ON DELETE CASCADE
	ON UPDATE CASCADE;
PRINT '- FK [FK_BatchProcessingLog_ActivityTypeLookup_ActivityTypeID] Created';

ALTER TABLE dbo.BatchProcessingLog CHECK CONSTRAINT FK_BatchProcessingLog_ActivityTypeLookup_ActivityTypeID;
PRINT '- FK [FK_BatchProcessingLog_ActivityTypeLookup_ActivityTypeID] Enabled';
GO

ALTER TABLE dbo.BatchProcessingLog WITH NOCHECK
ADD CONSTRAINT FK_BatchProcessingLog_BatchQueue_BatchId
    FOREIGN KEY ( BatchId )
    REFERENCES dbo.BatchQueue ( BatchId ) 
	ON DELETE CASCADE
	ON UPDATE CASCADE;
PRINT '- FK [FK_BatchProcessingLog_BatchQueue_BatchId] Created';

ALTER TABLE dbo.BatchProcessingLog CHECK CONSTRAINT FK_BatchProcessingLog_BatchQueue_BatchId;
PRINT '- FK [FK_BatchProcessingLog_BatchQueue_BatchId] Enabled';
GO


PRINT 'Working on table [dbo].[ShipmentQueue] ...';

ALTER TABLE dbo.ShipmentQueue WITH NOCHECK
ADD CONSTRAINT FK_ShipmentQueue_BatchQueue_BatchId
    FOREIGN KEY ( BatchId )
    REFERENCES dbo.BatchQueue ( BatchId ) 
	ON DELETE CASCADE
	ON UPDATE CASCADE;
PRINT '- FK [FK_ShipmentQueue_BatchQueue_BatchId] Created';

ALTER TABLE dbo.ShipmentQueue CHECK CONSTRAINT FK_ShipmentQueue_BatchQueue_BatchId;
PRINT '- FK [FK_ShipmentQueue_BatchQueue_BatchId] Enabled';
GO

ALTER TABLE dbo.ShipmentQueue WITH NOCHECK
ADD CONSTRAINT FK_ShipmentQueue_TransactionTypeLookup_TypeID
    FOREIGN KEY ( TransactionTypeId )
    REFERENCES dbo.TransactionTypeLookup ( TypeID ) 
	ON DELETE CASCADE
	ON UPDATE CASCADE;
PRINT '- FK [FK_ShipmentQueue_TransactionTypeLookup_TypeID] Created';

ALTER TABLE dbo.ShipmentQueue CHECK CONSTRAINT FK_ShipmentQueue_TransactionTypeLookup_TypeID;
PRINT '- FK [FK_ShipmentQueue_TransactionTypeLookup_TypeID] Enabled';
GO


--===================================================================================================
--[UPDATE STATS]
--===================================================================================================
PRINT '********************';
PRINT '*** Update Stats ***';
PRINT '********************';

--************************************************
PRINT 'Working on table [dbo].[tableName] ...';

UPDATE STATISTICS dbo.BatchProcessingLog;
PRINT '- Statistics Updated';

UPDATE STATISTICS dbo.ShipmentQueue;
PRINT '- Statistics Updated';

--===================================================================================================
--[DONE]
--===================================================================================================
PRINT '***********************';
PRINT '!!! Script COMPLETE !!!';
PRINT '***********************';