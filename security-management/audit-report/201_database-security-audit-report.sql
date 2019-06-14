--RUN THIS SCRIPT ON EVERY DATABASE OF THE INSTANCE

DECLARE @cmd VARCHAR(MAX)

SET @cmd ='IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].SecAuditPermissions'') AND type IN (N''P'', N''PC''))
BEGIN
EXEC dbo.sp_executesql @statement = N''CREATE PROCEDURE [dbo].SecAuditPermissions AS'' 
END'+CHAR(10)+'GO'+CHAR(10)+
'ALTER PROCEDURE SecAuditPermissions
as
DECLARE @p_userName NVARCHAR(50) 
SET @p_userName = '''' -- Specify up to five characters here (or none for all users)

/*
Security Audit Report
1) List all access provisioned to a sql user or windows user/group directly 
2) List all access provisioned to a sql user or windows user/group through a database or application role
3) List all access provisioned to the public role

Columns Returned:
UserName        : SQL or Windows/Active Directory user cccount.  This could also be an            Active Directory group.
UserType        : Value will be either ''SQL User'' or ''Windows User''.  This reflects the type of user defined for the  SQL Server user account.
DatabaseUserName: Name of the associated user as defined in the database user account.  The database user may not be the same as the server user.
Role            : The role name.  This will be null if the associated permissions to the object are defined at directly on the user account, otherwise this will be the name of the role that the user is a member of.
PermissionType  : Type of permissions the user/role has on an object. Examples could include CONNECT, EXECUTE, SELECT, DELETE, INSERT, ALTER, CONTROL, TAKE OWNERSHIP, VIEW DEFINITION, etc. This value may not be populated for all roles.  Some built in roles have implicit permission definitions.
PermissionState : Reflects the state of the permission type, examples could include GRANT, DENY, etc. This value may not be populated for all roles.  Some built in roles have implicit permission definitions.
ObjectType      : Type of object the user/role is assigned permissions on.  Examples could include USER_TABLE, SQL_SCALAR_FUNCTION, SQL_INLINE_TABLE_VALUED_FUNCTION, SQL_STORED_PROCEDURE, VIEW, etc. This value may not be populated for all roles.  Some built in roles have implicit permission definitions.          
ObjectName      : Name of the object that the user/role is assigned permissions on. This value may not be populated for all roles.  Some built in roles have implicit permission definitions.
ColumnName      : Name of the column of the object that the user/role is assigned permissions on. This value is only populated if the object is a table, view or a table value function. 

*/

DECLARE @userName NVARCHAR(4)
SET  @userName = @p_UserName + ''%''

SELECT  DB_NAME(),
[DatabaseUserName] = princ.[name],    
[UserType] = CASE princ.[type]
                WHEN ''S'' THEN ''SQL User''
                WHEN ''U'' THEN ''Windows User''
             END,  
   
[Role] = null,      
[PermissionType] = perm.[permission_name],       
[PermissionState] = perm.[state_desc],       
[ObjectType] = obj.type_desc,
[ObjectName] = OBJECT_NAME(perm.major_id),
[ColumnName] = col.[name]
FROM    
sys.database_principals princ  
LEFT JOIN
sys.login_token ulogin on princ.[sid] = ulogin.[sid]
LEFT JOIN        
sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
LEFT JOIN
sys.columns col ON col.[object_id] = perm.major_id 
                AND col.[column_id] = perm.[minor_id]
LEFT JOIN
sys.objects obj ON perm.[major_id] = obj.[object_id]
WHERE 
princ.[type] in (''S'',''U'')  
AND princ.[name] LIKE @userName  -- Added this line --CSLAGLE
UNION
SELECT  DB_NAME(),
[DatabaseUserName] = memberprinc.[name],   
[UserType] = CASE memberprinc.[type]
                WHEN ''S'' THEN ''SQL User''
                WHEN ''U'' THEN ''Windows User''
             END, 

[Role] = roleprinc.[name],      
[PermissionType] = perm.[permission_name],       
[PermissionState] = perm.[state_desc],       
[ObjectType] = obj.type_desc,
[ObjectName] = OBJECT_NAME(perm.major_id),
[ColumnName] = col.[name]
FROM    
sys.database_role_members members JOIN
sys.database_principals roleprinc ON roleprinc.[principal_id] = members.[role_principal_id]
JOIN 
sys.database_principals memberprinc ON memberprinc.[principal_id] = members.[member_principal_id]
LEFT JOIN
sys.login_token ulogin on memberprinc.[sid] = ulogin.[sid]
LEFT JOIN        
sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN
sys.columns col on col.[object_id] = perm.major_id 
                AND col.[column_id] = perm.[minor_id]
LEFT JOIN
sys.objects obj ON perm.[major_id] = obj.[object_id]
WHERE memberprinc.[name] LIKE @userName -- Added this line --CSLAGLE
UNION
SELECT  DB_NAME(),
--[UserName] = ''{All Users}'', 
[DatabaseUserName] = ''{All Users}'',  
[UserType] = ''{All Users}'', 
[Role] = roleprinc.[name],      
[PermissionType] = perm.[permission_name],       
[PermissionState] = perm.[state_desc],       
[ObjectType] = obj.type_desc,
[ObjectName] = OBJECT_NAME(perm.major_id),
[ColumnName] = col.[name]
FROM    
sys.database_principals roleprinc
LEFT JOIN        
sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN
sys.columns col on col.[object_id] = perm.major_id 
                AND col.[column_id] = perm.[minor_id]                   
JOIN 
sys.objects obj ON obj.[object_id] = perm.[major_id]
WHERE
roleprinc.[type] = ''R'' AND
roleprinc.[name] = ''public'' AND
obj.is_ms_shipped = 0
ORDER BY
princ.[Name],
OBJECT_NAME(perm.major_id),
col.[name],
perm.[permission_name],
perm.[state_desc],
obj.type_desc'

DECLARE @dbname VARCHAR(100),@cmd2 VARCHAR(max)
SET @cmd2=''

DECLARE cur CURSOR FOR 
SELECT name FROM sys.databases WHERE is_read_only=0 and state_desc not in ('OFFLINE') AND name NOT LIKE 'ReportServer%' AND name NOT LIKE 'tempdb%' AND name NOT IN('master','msdb')
OPEN cur
FETCH NEXT FROM cur INTO @dbname
WHILE @@FETCH_STATUS <> -1
BEGIN

SET @cmd2 = 'use '+@dbname+CHAR(10)+'GO'+CHAR(10)+@cmd+CHAR(10)+'GO'+CHAR(10)
print(@cmd2); 
--EXEC (@cmd2); 

FETCH NEXT FROM cur INTO @dbname
end
CLOSE cur
DEALLOCATE cur
