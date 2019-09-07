
------------------------------------------------------
-- CHANGE BELOW TO YOUR TEAM NUMBER (REPLACE XX)
USE [TEAMXX_TenantDataDb]
GO
------------------------------------------------------

EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM01_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM01', NULL, 'TEAM01';
EXEC [TEAM01_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM01', NULL, 'TEAM01';
EXEC [TEAM01_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM01', NULL, 'TEAM01';

ALTER DATABASE [TEAM01_TenantDataDb] SET TRUSTWORTHY ON; 
GO