--Grabbing all the jobs that are not owned by sa 
SELECT 'EXEC msdb.dbo.sp_update_job @job_id=N'''+CONVERT(VARCHAR(64),job_id)+''',@owner_login_name=N''sa''',* FROM msdb.dbo.sysjobs WHERE owner_sid != 0x01 ORDER BY name