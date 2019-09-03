USE master
GO
EXEC sp_configure "CLR Enabled", 1
RECONFIGURE WITH OVERRIDE

-- Implement DB Restore Fixes
--------------------------------------------------
USE [TEAM01_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM01_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM01', NULL, 'TEAM01';
EXEC [TEAM01_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM01', NULL, 'TEAM01';
EXEC [TEAM01_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM01', NULL, 'TEAM01';

ALTER DATABASE [TEAM01_TenantDataDb] SET TRUSTWORTHY ON; 
GO
---------------------------------------------------
USE [TEAM02_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM02_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM02', NULL, 'TEAM02';
EXEC [TEAM02_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM02', NULL, 'TEAM02';
EXEC [TEAM02_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM02', NULL, 'TEAM02';

ALTER DATABASE [TEAM02_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM03_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM03_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM03', NULL, 'TEAM03';
EXEC [TEAM03_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM03', NULL, 'TEAM03';
EXEC [TEAM03_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM03', NULL, 'TEAM03';

ALTER DATABASE [TEAM03_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM04_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM04_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM04', NULL, 'TEAM04';
EXEC [TEAM04_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM04', NULL, 'TEAM04';
EXEC [TEAM04_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM04', NULL, 'TEAM04';

ALTER DATABASE [TEAM04_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM05_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM05_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM05', NULL, 'TEAM05';
EXEC [TEAM05_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM05', NULL, 'TEAM05';
EXEC [TEAM05_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM05', NULL, 'TEAM05';

ALTER DATABASE [TEAM05_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM06_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM06_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM06', NULL, 'TEAM06';
EXEC [TEAM06_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM06', NULL, 'TEAM06';
EXEC [TEAM06_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM06', NULL, 'TEAM06';

ALTER DATABASE [TEAM06_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM07_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM07_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM07', NULL, 'TEAM07';
EXEC [TEAM07_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM07', NULL, 'TEAM07';
EXEC [TEAM07_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM07', NULL, 'TEAM07';

ALTER DATABASE [TEAM07_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM08_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM08_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM08', NULL, 'TEAM08';
EXEC [TEAM08_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM08', NULL, 'TEAM08';
EXEC [TEAM08_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM08', NULL, 'TEAM08';

ALTER DATABASE [TEAM08_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM09_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM09_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM09', NULL, 'TEAM09';
EXEC [TEAM09_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM09', NULL, 'TEAM09';
EXEC [TEAM09_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM09', NULL, 'TEAM09';

ALTER DATABASE [TEAM09_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM10_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM10_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM10', NULL, 'TEAM10';
EXEC [TEAM10_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM10', NULL, 'TEAM10';
EXEC [TEAM10_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM10', NULL, 'TEAM10';

ALTER DATABASE [TEAM10_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM11_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM11_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM11', NULL, 'TEAM11';
EXEC [TEAM11_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM11', NULL, 'TEAM11';
EXEC [TEAM11_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM11', NULL, 'TEAM11';

ALTER DATABASE [TEAM11_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM12_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM12_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM12', NULL, 'TEAM12';
EXEC [TEAM12_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM12', NULL, 'TEAM12';
EXEC [TEAM12_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM12', NULL, 'TEAM12';

ALTER DATABASE [TEAM12_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM13_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM13_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM13', NULL, 'TEAM13';
EXEC [TEAM13_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM13', NULL, 'TEAM13';
EXEC [TEAM13_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM13', NULL, 'TEAM13';

ALTER DATABASE [TEAM13_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM14_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM14_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM14', NULL, 'TEAM14';
EXEC [TEAM14_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM14', NULL, 'TEAM14';
EXEC [TEAM14_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM14', NULL, 'TEAM14';

ALTER DATABASE [TEAM14_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM15_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM15_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM15', NULL, 'TEAM15';
EXEC [TEAM15_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM15', NULL, 'TEAM15';
EXEC [TEAM15_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM15', NULL, 'TEAM15';

ALTER DATABASE [TEAM15_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM16_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM16_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM16', NULL, 'TEAM16';
EXEC [TEAM16_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM16', NULL, 'TEAM16';
EXEC [TEAM16_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM16', NULL, 'TEAM16';

ALTER DATABASE [TEAM16_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM17_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM17_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM17', NULL, 'TEAM17';
EXEC [TEAM17_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM17', NULL, 'TEAM17';
EXEC [TEAM17_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM17', NULL, 'TEAM17';

ALTER DATABASE [TEAM17_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM18_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM18_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM18', NULL, 'TEAM18';
EXEC [TEAM18_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM18', NULL, 'TEAM18';
EXEC [TEAM18_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM18', NULL, 'TEAM18';

ALTER DATABASE [TEAM18_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM19_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM19_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM19', NULL, 'TEAM19';
EXEC [TEAM19_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM19', NULL, 'TEAM19';
EXEC [TEAM19_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM19', NULL, 'TEAM19';

ALTER DATABASE [TEAM19_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------
USE [TEAM20_TenantDataDb]
GO
EXEC dbo.sp_changedbowner 'sa'
EXEC [TEAM20_TenantDataDb].dbo.sp_change_users_login 'Auto_Fix', 'TEAM20', NULL, 'TEAM20';
EXEC [TEAM20_SharedMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM20', NULL, 'TEAM20';
EXEC [TEAM20_LocalMasterDataDB].dbo.sp_change_users_login 'Auto_Fix', 'TEAM20', NULL, 'TEAM20';

ALTER DATABASE [TEAM20_TenantDataDb] SET TRUSTWORTHY ON; 
GO
--------------------------------------------------