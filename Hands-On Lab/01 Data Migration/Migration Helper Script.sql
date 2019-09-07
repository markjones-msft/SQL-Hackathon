
------------------------------------------------------
-- CHANGE BELOW TO YOUR TEAM NUMBER (REPLACE XX)
USE [TEAMXX_TenantDataDb]
GO
------------------------------------------------------

EXEC dbo.sp_changedbowner 'sa'

alter database [LocalMasterDataDB] set trustworthy on
go
alter database [SharedMasterDataDB] set trustworthy on
go
alter database [TenantDataDb] set trustworthy on
go
