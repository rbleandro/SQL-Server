select 'exec msdb.dbo.sp_update_job @job_id=N''' + cast(job_id as varchar(100)) + ''', @enabled=0' 
FROM msdb.dbo.sysjobs_view
WHERE name NOT LIKE 'DBA%'
AND enabled=1

exec msdb.dbo.sp_update_job @job_id=N'A982DDAF-D101-4B26-BB99-0D1C61141390', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'3EB16EE8-0965-4060-9E81-21BF5B1B827F', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'08F86185-0AC1-4FA9-8DD6-23F8AEB8DF8E', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'8E0B8885-E2C5-4BB1-9D9A-27B62712535A', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'8C12B0B3-0FBF-4929-AE7F-3E05B15D158B', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'F49F2A1E-8132-4A0D-B21F-3F85449A0B0D', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'949790C1-C2AB-4EC7-A434-41F62DC5BFE9', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'49CCB08C-F04C-4669-AE0E-6AACFF3CD6D6', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'0B37808D-029C-4698-B966-6F46B482AAE4', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'BB5A3E88-1DB7-4744-A15A-7011189C316F', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'9BED5C19-D28F-4E62-A01E-78BEA30E878F', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'8288D782-326B-41DC-97C6-85D54E08BA48', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'DFEE20C5-E223-4A51-B319-874B923B2BB0', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'13122367-897E-4A02-8025-9D17732686B3', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'DACB01B5-573C-4249-BDE7-A0BAAE462B54', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'95629626-ABCC-4920-9C83-A3262730F52D', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'36C38441-722A-447C-B838-D96EAC435CD0', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'3B45C59B-BC85-4BDC-8C63-E4AFC01CEB9D', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'C1C2E611-E21B-4549-A5D7-EED8925656F5', @enabled=0
exec msdb.dbo.sp_update_job @job_id=N'AF0D3B62-D6E6-4F29-B44A-F4A683CB6E9B', @enabled=0