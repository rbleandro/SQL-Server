--run more than once if necessary until you get no errors


USE [master]
GO
ALTER DATABASE [NetPerfMon] MODIFY FILE ( NAME = N'LogSec', MAXSIZE = UNLIMITED, FILEGROWTH = 0)
GO

USE [NetPerfMon]
GO
BACKUP LOG [NetPerfMon] TO DISK='g:\dbbackups\NetPerfMon_log_1.trn' WITH COMPRESSION
BACKUP LOG [NetPerfMon] TO DISK='g:\dbbackups\NetPerfMon_log_2.trn' WITH COMPRESSION
BACKUP LOG [NetPerfMon] TO DISK='g:\dbbackups\NetPerfMon_log_3.trn' WITH COMPRESSION
BACKUP LOG [NetPerfMon] TO DISK='g:\dbbackups\NetPerfMon_log_4.trn' WITH COMPRESSION
BACKUP LOG [NetPerfMon] TO DISK='g:\dbbackups\NetPerfMon_log_5.trn' WITH compression
BACKUP LOG [NetPerfMon] TO DISK='g:\dbbackups\NetPerfMon_log_6.trn' WITH COMPRESSION
BACKUP LOG [NetPerfMon] TO DISK='g:\dbbackups\NetPerfMon_log_7.trn' WITH COMPRESSION
BACKUP LOG [NetPerfMon] TO DISK='g:\dbbackups\NetPerfMon_log_8.trn' WITH COMPRESSION
BACKUP LOG [NetPerfMon] TO DISK='g:\dbbackups\NetPerfMon_log_9.trn' WITH COMPRESSION
BACKUP LOG [NetPerfMon] TO DISK='g:\dbbackups\NetPerfMon_log_10.trn' WITH COMPRESSION
DBCC SHRINKFILE (N'LogSec' , 1)
DBCC SHRINKFILE ('LogSec', EMPTYFILE);
--checkpoint
ALTER DATABASE [NetPerfMon]  REMOVE FILE [LogSec]
GO

--run dbcc loginfo to confirm that the log file is not being used anymore. To check the file id, check sys.database_files dmv
DBCC LogInfo

