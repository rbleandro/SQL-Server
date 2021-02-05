DECLARE @Hash varchar(100)

SELECT @Hash = 'Encrypted Text'
SELECT HashBytes('MD5', @Hash)

SELECT @Hash = 'Encrypted Text'
SELECT HashBytes('SHA', @Hash)


DECLARE @Hash varchar(100)
SELECT @Hash = 'encrypted text'
SELECT HashBytes('SHA1', @Hash)
SELECT @Hash = 'ENCRYPTED TEXT'
SELECT HashBytes('SHA1', @Hash)


-------------------------------------

DECLARE @EncryptedText   VARBINARY(80)
SELECT @EncryptedText = 
    EncryptByPassphrase('alucard__535','Encrypted Text')
SELECT @EncryptedText, 
    CAST(DecryptByPassPhrase('alucard__535',@EncryptedText) 
    AS VARCHAR(MAX))
   
-----------------------------

CREATE SYMMETRIC KEY TestSymmetricKey WITH ALGORITHM = RC4
    ENCRYPTION BY PASSWORD = 'alucard__535'
SELECT * FROM sys.symmetric_keys

 --Execute the following code to open the symmetric key: 
OPEN SYMMETRIC KEY TestSymmetricKey 
    DECRYPTION BY PASSWORD = 'alucard__535'
    
 --Execute the following code to view the data encrypted with the symmetric key: 
DECLARE @EncryptedText   VARBINARY(80)
SELECT @EncryptedText = 
    EncryptByKey(Key_GUID('TestSymmetricKey'),'Encrypted Text')
SELECT @EncryptedText, CAST(DecryptByKey(@EncryptedText) AS VARCHAR(30))

 --Execute the following code to close the symmetric key: 
CLOSE SYMMETRIC KEY TestSymmetricKey
GO

-------------------------


USE master
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'alucard__535'
GO
CREATE CERTIFICATE ServerCert WITH SUBJECT = 'My Server Cert for TDE'
GO

BACKUP CERTIFICATE ServerCert TO FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\Backup\servercert.cer'
WITH PRIVATE KEY (FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\Backup\servercert.key',ENCRYPTION BY PASSWORD = 'alucard__535')
    

USE AdventureWorks
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE ServerCert
GO

ALTER DATABASE AdventureWorks
SET ENCRYPTION ON
GO

-------------------------


CREATE TABLE dbo.CertificateEncryption
(ID         INT             IDENTITY(1,1),
SalesRep    VARCHAR(30)     NOT NULL,
SalesLead   VARBINARY(500)  NOT NULL)
GO
CREATE USER SalesRep1 WITHOUT LOGIN
GO
CREATE USER SalesRep2 WITHOUT LOGIN
GO
GRANT SELECT, INSERT ON dbo.CertificateEncryption TO SalesRep1
GRANT SELECT, INSERT ON dbo.CertificateEncryption TO SalesRep2
GO


USE AdventureWorks
GO


CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'alucard__535'
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = 'alucard__535';


CREATE CERTIFICATE SalesRep1Cert AUTHORIZATION SalesRep1
    WITH SUBJECT = 'SalesRep 1 certificate'
GO
CREATE CERTIFICATE SalesRep2Cert AUTHORIZATION SalesRep2
    WITH SUBJECT = 'SalesRep 2 certificate'
GO
SELECT * FROM sys.certificates
GO


EXECUTE AS USER='SalesRep1'
GO
INSERT INTO dbo.CertificateEncryption
(SalesRep, SalesLead)
VALUES('SalesRep1',EncryptByCert(Cert_ID('SalesRep1Cert'), 'Fabrikam'))
REVERT
GO

EXECUTE AS USER='SalesRep2'
GO
INSERT INTO dbo.CertificateEncryption
(SalesRep, SalesLead)
VALUES('SalesRep2',EncryptByCert(Cert_ID('SalesRep2Cert'), 'Contoso'))
REVERT
GO

SELECT ID, SalesRep, SalesLead
FROM dbo.CertificateEncryption
GO

EXECUTE AS USER='SalesRep1'
GO
SELECT ID, SalesRep, SalesLead, 
    CAST(DecryptByCert(Cert_Id('SalesRep1Cert'), SalesLead) 
        AS VARCHAR(MAX))
FROM dbo.CertificateEncryption
REVERT
GO

EXECUTE AS USER='SalesRep2'
GO
SELECT ID, SalesRep, SalesLead, 
    CAST(DecryptByCert(Cert_Id('SalesRep2Cert'), SalesLead) 
        AS VARCHAR(MAX))
FROM dbo.CertificateEncryption
REVERT
GO