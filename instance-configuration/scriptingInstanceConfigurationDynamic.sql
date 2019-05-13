SET NOCOUNT ON

USE master
GO


EXEC sp_configure 'show advanced options',1
reconfigure

if object_id('config') is null
CREATE TABLE config
(
nome VARCHAR(50), minimum INT, maximum INT, config_value INT, run_value int
);
go


truncate table config
INSERT config
EXEC sp_configure

select 'exec sp_configure ''' + nome + ''',' + cast(run_value as varchar) + char(13) + 'reconfigure' from master.dbo.config
