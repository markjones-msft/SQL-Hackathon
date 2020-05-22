-- Post Build tasks to be run on the Managed instance
-- Please replace <Enter Blob URL Here> with the blob container URL
-- Please replace <Enter Key here> with SAS key
-- The backups to restore can be found in the repository folder SQL SSIS Databases, you will need to upload these to a blob store
-- For more informatgion on how to restore databases from URL see https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance-get-started-restore

USE master
GO
EXEC sp_configure "CLR Enabled", 1
RECONFIGURE WITH OVERRIDE
GO


-- For more information 
CREATE CREDENTIAL [<Enter Blob URL Here>] WITH IDENTITY='Shared Access Signature', SECRET='<Enter Key here>';
GO

RESTORE DATABASE [LocalMasterDataDb] FROM URL = '<Enter Blob URL Here>/LocalMasterDataDb.bak';
GO

RESTORE DATABASE [SharedMasterDataDb] FROM URL = '<Enter Blob URL Here>/SharedMasterDataDB.bak';
GO

RESTORE DATABASE [TenantDataDb] FROM URL = '<Enter Blob URL Here>/TenantDataDb.bak';      
GO

RESTORE DATABASE [2008DW] FROM URL = '<Enter Blob URL Here>/2008DW.bak';
GO

