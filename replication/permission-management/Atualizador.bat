rem atualizacao dos scripts
sqlcmd -S 10.140.1.16,1190 -d db_prd_corp -U usr_pf_web -P AQ!@WS#EDaq12ws3ed -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_InsertDelete.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_InsertDeleteComando.sql"
sqlcmd -S 10.140.1.16,1190 -d db_prd_corp -U usr_pf_web -P AQ!@WS#EDaq12ws3ed -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_Update.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_UpdateComando.sql"

rem aplicacao em homologacao
sqlcmd -S 10.140.1.232,1145 -d db_hom_pontofrio -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\RecriaRoleAdmReplicacao.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_RecriaRoleAdmReplicacao_pf_homol.sql"
sqlcmd -S 10.140.1.232,1145 -d db_hom_extra -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\RecriaRoleAdmReplicacao.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_RecriaRoleAdmReplicacao_ex_homol.sql"
sqlcmd -S 10.140.1.232,1145 -d db_hom_casasbahia -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\RecriaRoleAdmReplicacao.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_RecriaRoleAdmReplicacao_cb_homol.sql"

sqlcmd -S 10.140.1.232,1145 -d db_hom_pontofrio -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_UpdateComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_UpdateComando_pf_homol.sql"
sqlcmd -S 10.140.1.232,1145 -d db_hom_extra -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_UpdateComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_UpdateComando_ex_homol.sql"
sqlcmd -S 10.140.1.232,1145 -d db_hom_casasbahia -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_UpdateComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_UpdateComando_cb_homol.sql"

sqlcmd -S 10.140.1.232,1145 -d db_hom_pontofrio -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_InsertDeleteComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_InsertDeleteComando_pf_homol.sql"
sqlcmd -S 10.140.1.232,1145 -d db_hom_extra -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_InsertDeleteComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_InsertDeleteComando_ex_homol.sql"
sqlcmd -S 10.140.1.232,1145 -d db_hom_casasbahia -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_InsertDeleteComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_InsertDeleteComando_cb_homol.sql"


rem aplicacao em desenvolvimento
sqlcmd -S 10.140.1.231,1198 -d db_des_pontofrio -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\RecriaRoleAdmReplicacao.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_RecriaRoleAdmReplicacao_pf_dev.sql"
sqlcmd -S 10.140.1.231,1198 -d db_des_extra -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\RecriaRoleAdmReplicacao.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_RecriaRoleAdmReplicacao_ex_dev.sql"
sqlcmd -S 10.140.1.231,1198 -d db_des_casasbahia -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\RecriaRoleAdmReplicacao.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_RecriaRoleAdmReplicacao_cb_dev.sql"

sqlcmd -S 10.140.1.231,1198 -d db_des_pontofrio -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_UpdateComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_UpdateComando_pf_dev.sql"
sqlcmd -S 10.140.1.231,1198 -d db_des_extra -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_UpdateComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_UpdateComando_ex_dev.sql"
sqlcmd -S 10.140.1.231,1198 -d db_des_casasbahia -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_UpdateComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_UpdateComando_cb_dev.sql"

sqlcmd -S 10.140.1.231,1198 -d db_des_pontofrio -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_InsertDeleteComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_InsertDeleteComando_pf_dev.sql"
sqlcmd -S 10.140.1.231,1198 -d db_des_extra -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_InsertDeleteComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_InsertDeleteComando_ex_dev.sql"
sqlcmd -S 10.140.1.231,1198 -d db_des_casasbahia -U rafael.bahia -P alucard__535 -i "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Deny_InsertDeleteComando.sql" -o "c:\DropBox\Dropbox\Processos\Monitoracao\ADM\ScriptWH\REPLICACAO\AjustePermissoes\Resultado_Deny_InsertDeleteComando_cb_dev.sql"
