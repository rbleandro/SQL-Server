USE [msdb]
GO
/****** Object:  ProxyAccount [Administrator_win]    Script Date: 01/15/2010 15:26:27 ******/
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'Administrator_win',@credential_name=N'cred_adm', 
		@enabled=1
GO
/****** Object:  ProxyAccount [Cluster_service]    Script Date: 01/15/2010 15:26:27 ******/
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'Cluster_service',@credential_name=N'cred_service_sql', 
		@enabled=1

/****** Adding proxies to the necessary subsystems ********/
USE [msdb]
GO
EXEC msdb.dbo.sp_update_proxy @proxy_name=N'Administrator_win',@credential_name=N'cred_adm', 
		@description=N''
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Administrator_win', @subsystem_id=2
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Administrator_win', @subsystem_id=3
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Administrator_win', @subsystem_id=6
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Administrator_win', @subsystem_id=7
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Administrator_win', @subsystem_id=8
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Administrator_win', @subsystem_id=4
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Administrator_win', @subsystem_id=5
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Administrator_win', @subsystem_id=10
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Administrator_win', @subsystem_id=9
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Administrator_win', @subsystem_id=11
GO



USE [msdb]
GO
EXEC msdb.dbo.sp_update_proxy @proxy_name=N'Cluster_service',@credential_name=N'cred_service_sql', 
		@description=N''
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Cluster_service', @subsystem_id=2
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Cluster_service', @subsystem_id=3
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Cluster_service', @subsystem_id=6
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Cluster_service', @subsystem_id=7
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Cluster_service', @subsystem_id=8
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Cluster_service', @subsystem_id=4
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Cluster_service', @subsystem_id=5
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Cluster_service', @subsystem_id=10
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Cluster_service', @subsystem_id=9
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'Cluster_service', @subsystem_id=11
GO