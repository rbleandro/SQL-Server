EXEC sp_xp_cmdshell_proxy_account 'CANPARNT\sorteradmin','SA!Canpar12'

exec xp_cmdshell 'net use X: \\CPRHQVFS4\Source\Backups\JCC-Backups /USER:CANPARNT\sorteradmin SA!Canpar12'
EXEC sys.xp_cmdshell 'copy S:\DB_Backups\SmartSort_Canpar_SCS_20181030_234500.trn X:\'
EXEC sys.xp_cmdshell 'copy S:\DB_Backups\SmartSort_Canpar_SCS_20181030_234500.trn \\CPRHQVFS4\Source\Backups\JCC-Backups\ /Y /V'
EXEC sys.xp_cmdshell 'copy S:\DB_Backups\SmartSort_Canpar_SCS_20181030_234500.trn S:\DB_Backups\test\ /Y /V'
EXEC sys.xp_cmdshell 'dir X:\'
EXEC sys.xp_cmdshell 'dir S:\DB_Backups'
exec xp_cmdshell 'net use X: /delete /Y'

EXEC sys.xp_cmdshell 'copy S:\DB_Backups\SmartSort_Canpar_SCS_20181030_234500.trn Z:\ /Y /V'
GO

DECLARE @copyCmd VARCHAR(2000)='dir S:\DB_Backups'
EXEC sys.xp_cmdshell @copyCmd;




--xp_cmdshell 'whoami.exe'
