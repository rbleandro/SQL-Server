/*
remarks:

1. Use this script to generate the script to kill connections on a database, detach and attach a database
2. The script to create the procedure 'proc_kill_processes_por_database is provided in the repository

*/

USE master
go

select 'exec master.dbo.[proc_kill_processes_por_database] @dbname = ' + name from sys.databases where database_id > 4

select 'EXEC master.dbo.sp_detach_db @dbname='''+name+''',@keepfulltextindexfile=N''true'''
from sys.databases where database_id > 4

select distinct 'CREATE DATABASE ['+ db_name(dbid) + '] ON ( FILENAME = N'''+dbo.pegaArquivosBD(db_name(dbid),1)+''' ),( FILENAME = N'''+dbo.pegaArquivosBD(db_name(dbid),2)+''' ) FOR ATTACH ' 
from sys.sysaltfiles 

exec master.dbo.[proc_kill_processes_por_database] @dbname = '2017 Oct - Dec_01'
exec master.dbo.[proc_kill_processes_por_database] @dbname = '2018 Jan - Mar'
exec master.dbo.[proc_kill_processes_por_database] @dbname = '2018 Apr - Jun'
exec master.dbo.[proc_kill_processes_por_database] @dbname = '2018 Jul - Sep'
exec master.dbo.[proc_kill_processes_por_database] @dbname = '2018 Oct - Dec'

EXEC master.dbo.sp_detach_db @dbname='2017 Oct - Dec_01',@keepfulltextindexfile=N'true'
EXEC master.dbo.sp_detach_db @dbname='2018 Apr - Jun',@keepfulltextindexfile=N'true'
EXEC master.dbo.sp_detach_db @dbname='2018 Jan - Mar',@keepfulltextindexfile=N'true'
EXEC master.dbo.sp_detach_db @dbname='2018 Jul - Sep',@keepfulltextindexfile=N'true'
EXEC master.dbo.sp_detach_db @dbname='2018 Oct - Dec',@keepfulltextindexfile=N'true'

CREATE DATABASE [2017 Oct - Dec_01] ON ( FILENAME = N'E:\DATA\2017 Oct - Dec_01.mdf' ),( FILENAME = N'F:\LOG\2017 Oct - Dec_01_log.ldf' ) FOR ATTACH 
CREATE DATABASE [2018 Apr - Jun] ON ( FILENAME = N'E:\DATA\2018 Apr - Jun.mdf' ),( FILENAME = N'F:\LOG\2018 Apr - Jun_log.ldf' ) FOR ATTACH 
CREATE DATABASE [2018 Jan - Mar] ON ( FILENAME = N'E:\DATA\2018 Jan - Mar.mdf' ),( FILENAME = N'F:\LOG\2018 Jan - Mar_log.ldf' ) FOR ATTACH 
CREATE DATABASE [2018 Jul - Sep] ON ( FILENAME = N'E:\DATA\2018 Jul - Sep.mdf' ),( FILENAME = N'F:\LOG\2018 Jul - Sep_log.ldf' ) FOR ATTACH 
CREATE DATABASE [2018 Oct - Dec] ON ( FILENAME = N'E:\DATA\2018 Oct - Dec.mdf' ),( FILENAME = N'F:\LOG\2018 Oct - Dec_log.ldf' ) FOR ATTACH 

