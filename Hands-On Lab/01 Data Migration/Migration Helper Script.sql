
------------------------------------------------------
-- CHANGE BELOW TO YOUR TEAM NUMBER (REPLACE XX)
USE [TEAMXX_TenantDataDb]
GO
------------------------------------------------------

EXEC dbo.sp_changedbowner 'sa'

alter database [TEAMXX_LocalMasterDataDB] set trustworthy on
go
alter database [TEAMXX_SharedMasterDataDB] set trustworthy on
go
alter database [TEAMXX_TenantDataDb] set trustworthy on
go
