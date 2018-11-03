--TRUNCATE TABLE strings

SELECT linha 
FROM dbo.strings
WHERE linha !='</Build>'
AND linha != '</ItemGroup>'
AND linha != '<ItemGroup>'
AND linha != '<QuotedIdentifier>Off</QuotedIdentifier>'
AND linha != '<RefactorLog Include="GPA.Database.B2C.refactorlog" />'
AND linha != '</ItemGroup>'
AND linha NOT LIKE 'RN - %'
AND linha NOT LIKE 'OPER - %'
GROUP BY linha
HAVING COUNT(*) > 1

