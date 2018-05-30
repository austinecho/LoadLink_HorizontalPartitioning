/*
DataTeam
LoadLink Partitioning

•	ADD New File Group
•	ADD 2 Partition Functions
•	ADD 2 Partition Schemes

Run in DB01VPRD Equivalent
*/
USE LoadLink;
GO

IF ( SELECT @@SERVERNAME ) = 'DB01VPRD' BEGIN PRINT 'Running in Environment DB01VPRD...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'QA4-DB01' BEGIN PRINT 'Running in Environment QA4-DB01...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01' BEGIN PRINT 'Running in Environment DATATEAM4-DB01\DB01...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;

--===================================================================================================
--ADD FILEGROUP
--===================================================================================================
PRINT '*** ADD FILE GROUP AND FILE***';

IF NOT EXISTS ( SELECT 1 FROM sys.filegroups WHERE name = 'LoadLink_Archive' )
BEGIN 
	ALTER DATABASE LoadLink ADD FILEGROUP LoadLink_Archive;

	IF ( SELECT @@SERVERNAME ) = 'DB01VPRD'
	BEGIN
		--PROD --Note: N:\Data\EchoTrak.MDF --PRIMARY
		ALTER DATABASE LoadLink ADD FILE ( NAME = 'LoadLink_Archive', FILENAME = N'N:\Data\LoadLink_Archive.NDF', SIZE = 6GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP LoadLink_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) = 'QA4-DB01'
	BEGIN
		--QA4 --Note: N:\Data\EchoTrak.MDF --PRIMARY
		ALTER DATABASE LoadLink ADD FILE ( NAME = 'LoadLink_Archive', FILENAME = N'N:\Data\LoadLink_Archive.NDF', SIZE = 6GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP LoadLink_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01'
	BEGIN
		--DEV DT4 --Note: D:\Data\EchoTrak\EchoTrak_Primary.mdf --PRIMARY
		ALTER DATABASE LoadLink ADD FILE ( NAME = 'LoadLink_Archive', FILENAME = N'D:\Data\LoadLink_Archive.NDF', SIZE = 1GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP LoadLink_Archive;
		PRINT '- File [LoadLink_Archive] added';
	END;

	PRINT '- Filegroup [LoadLink_Archive] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Filegroup with same name already exists !!';
END;
GO

--===================================================================================================
--ADD PARTITION FUNCTION
--===================================================================================================
PRINT '*** ADD PARTITION FUNCTION ***';

IF NOT EXISTS ( SELECT 1 FROM sys.partition_functions WHERE name = 'PF_LoadLink_DATETIME_1Year' )
BEGIN
    CREATE PARTITION FUNCTION PF_LoadLink_DATETIME_1Year ( DATETIME ) AS RANGE RIGHT FOR VALUES ( '2017-01-01 00:00:00.000' ); 

    PRINT '- Partition Function [PF_LoadLink_DATETIME_1Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Function with same name already exists !!';
END;
GO

IF NOT EXISTS ( SELECT 1 FROM sys.partition_functions WHERE name = 'PF_LoadLink_INTEGER_1Year' )
BEGIN
    CREATE PARTITION FUNCTION PF_LoadLink_INTEGER_1Year ( INTEGER ) AS RANGE RIGHT FOR VALUES ( 303711 ); 

    PRINT '- Partition Function [PF_LoadLink_INTEGER_1Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Function with same name already exists !!';
END;
GO

--===================================================================================================
--ADD PARTITION SCHEME
--===================================================================================================
PRINT '*** ADD PARTITION SCHEME ***';

IF NOT EXISTS ( SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_LoadLink_DATETIME_1Year' )
BEGIN
    CREATE PARTITION SCHEME PS_LoadLink_DATETIME_1Year AS PARTITION PF_LoadLink_DATETIME_1Year TO ( LoadLink_Archive, [PRIMARY] );

	PRINT '- Partition Scheme [PS_LoadLink_DATETIME_1Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Scheme with same name already exists !!';
END;
GO

IF NOT EXISTS ( SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_LoadLink_INTEGER_1Year' )
BEGIN
    CREATE PARTITION SCHEME PS_LoadLink_INTEGER_1Year AS PARTITION PF_LoadLink_INTEGER_1Year TO ( LoadLink_Archive, [PRIMARY] );

	PRINT '- Partition Scheme [PS_LoadLink_INTEGER_1Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Scheme with same name already exists !!';
END;
GO

--Verify: Check existance
/*
SELECT * FROM sys.partition_functions WHERE name = 'PF_LoadLink_DATETIME_1Year';

SELECT * FROM sys.partition_schemes WHERE name = 'PS_LoadLink_DATETIME_1Year';

SELECT * FROM sys.filegroups WHERE name = 'LoadLink_Archive'

*/


