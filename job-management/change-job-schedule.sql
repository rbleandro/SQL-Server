EXEC msdb.dbo.sp_attach_schedule @job_id=N'd3a459cb-fb5a-4342-892b-3eb51ddb1d15',@schedule_id=1010
GO
USE [msdb]
GO
DECLARE @sid INT = (SELECT schedule_id FROM msdb.dbo.sysschedules WHERE name='every 10 minutes')
EXEC msdb.dbo.sp_update_schedule @schedule_id=1010, @active_start_time=70000
GO

SELECT schedule_id FROM msdb.dbo.sysschedules WHERE name='every 10 minutes'
SELECT TOP 10 * FROM msdb.dbo.sysjobschedules WHERE schedule_id= (SELECT schedule_id FROM msdb.dbo.sysschedules WHERE name='every 10 minutes')

