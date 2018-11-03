rem C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\VsDevCmd.bat
rem rodar no diretório onde o TFS está mapeado

D:
cd C:\TFS2015\GPA

CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\VsDevCmd.bat"

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-alm\src\main" 
tf workfold /map "$/GPA/apis/cnova-alm/src/main" "C:\TFS2015\GPA\apis\cnova-alm\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-alm/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\Branches\v4.0-GPA-Estoque" 
tf workfold /map "$/GPA/Branches/v4.0-GPA-Estoque" "C:\TFS2015\GPA\Branches\v4.0-GPA-Estoque" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/Branches/v4.0-GPA-Estoque" /recursive

del /F /S /Q "C:\TFS2015\Novos Negocios\Branches" 
tf workfold /map "$/Novos Negocios/Branches" "C:\TFS2015\Novos Negocios\Branches" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/Novos Negocios/Branches" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-analytics\src\main" 
tf workfold /map "$/GPA/apis/cnova-analytics/src/main" "C:\TFS2015\GPA\apis\cnova-analytics\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-analytics/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-api_parceiros\src\main" 
tf workfold /map "$/GPA/apis/cnova-api_parceiros/src/main" "C:\TFS2015\GPA\apis\cnova-api_parceiros\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-api_parceiros/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-atendimento\src\main" 
tf workfold /map "$/GPA/apis/cnova-atendimento/src/main" "C:\TFS2015\GPA\apis\cnova-atendimento\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-atendimento/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-busca\src\main" 
tf workfold /map "$/GPA/apis/cnova-busca/src/main" "C:\TFS2015\GPA\apis\cnova-busca\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-busca/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-cartaopresente\src\main" 
tf workfold /map "$/GPA/apis/cnova-cartaopresente/src/main" "C:\TFS2015\GPA\apis\cnova-cartaopresente\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-cartaopresente/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-catalogo\src\main" 
tf workfold /map "$/GPA/apis/cnova-catalogo/src/main" "C:\TFS2015\GPA\apis\cnova-catalogo\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-catalogo/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-corporativo\src\main" 
tf workfold /map "$/GPA/apis/cnova-corporativo/src/main" "C:\TFS2015\GPA\apis\cnova-corporativo\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-corporativo/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-entrega\src\main" 
tf workfold /map "$/GPA/apis/cnova-entrega/src/main" "C:\TFS2015\GPA\apis\cnova-entrega\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-entrega/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-erp\src\main" 
tf workfold /map "$/GPA/apis/cnova-erp/src/main" "C:\TFS2015\GPA\apis\cnova-erp\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-erp/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-gateway\src\main" 
tf workfold /map "$/GPA/apis/cnova-gateway/src/main" "C:\TFS2015\GPA\apis\cnova-gateway\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-gateway/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-listas\src\main" 
tf workfold /map "$/GPA/apis/cnova-listas/src/main" "C:\TFS2015\GPA\apis\cnova-listas\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-listas/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-loja\src\main" 
tf workfold /map "$/GPA/apis/cnova-loja/src/main" "C:\TFS2015\GPA\apis\cnova-loja\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-loja/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-marketing-b2b\src\main" 
tf workfold /map "$/GPA/apis/cnova-marketing-b2b/src/main" "C:\TFS2015\GPA\apis\cnova-marketing-b2b\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-marketing-b2b/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-marketing-b2c\src\main" 
tf workfold /map "$/GPA/apis/cnova-marketing-b2c/src/main" "C:\TFS2015\GPA\apis\cnova-marketing-b2c\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-marketing-b2c/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-marketplace\src\main" 
tf workfold /map "$/GPA/apis/cnova-marketplace/src/main" "C:\TFS2015\GPA\apis\cnova-marketplace\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-marketplace/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-meiosdepagamento\src\main" 
tf workfold /map "$/GPA/apis/cnova-meiosdepagamento/src/main" "C:\TFS2015\GPA\apis\cnova-meiosdepagamento\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-meiosdepagamento/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-parceiros-b2b\src\main" 
tf workfold /map "$/GPA/apis/cnova-parceiros-b2b/src/main" "C:\TFS2015\GPA\apis\cnova-parceiros-b2b\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-parceiros-b2b/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-preco\src\main" 
tf workfold /map "$/GPA/apis/cnova-preco/src/main" "C:\TFS2015\GPA\apis\cnova-preco\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-preco/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-productdetails\src\main" 
tf workfold /map "$/GPA/apis/cnova-productdetails/src/main" "C:\TFS2015\GPA\apis\cnova-productdetails\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-productdetails/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-seguranca\src\main" 
tf workfold /map "$/GPA/apis/cnova-seguranca/src/main" "C:\TFS2015\GPA\apis\cnova-seguranca\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-seguranca/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-serviceproxy\src\main" 
tf workfold /map "$/GPA/apis/cnova-serviceproxy/src/main" "C:\TFS2015\GPA\apis\cnova-serviceproxy\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-serviceproxy/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-serviceregistry\src\main" 
tf workfold /map "$/GPA/apis/cnova-serviceregistry/src/main" "C:\TFS2015\GPA\apis\cnova-serviceregistry\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-serviceregistry/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-social\src\main" 
tf workfold /map "$/GPA/apis/cnova-social/src/main" "C:\TFS2015\GPA\apis\cnova-social\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-social/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-utilitario\src\main" 
tf workfold /map "$/GPA/apis/cnova-utilitario/src/main" "C:\TFS2015\GPA\apis\cnova-utilitario\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-utilitario/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-workflow\src\main" 
tf workfold /map "$/GPA/apis/cnova-workflow/src/main" "C:\TFS2015\GPA\apis\cnova-workflow\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-workflow/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-cotador-b2b\src\main" 
tf workfold /map "$/GPA/apis/cnova-cotador-b2b/src/main" "C:\TFS2015\GPA\apis\cnova-cotador-b2b\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-cotador-b2b/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-geolocalizacao\src\main" 
tf workfold /map "$/GPA/apis/cnova-geolocalizacao/src/main" "C:\TFS2015\GPA\apis\cnova-geolocalizacao\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-geolocalizacao/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-maispontos\src\main" 
tf workfold /map "$/GPA/apis/cnova-maispontos/src/main" "C:\TFS2015\GPA\apis\cnova-maispontos\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-maispontos/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\cnova-transportadoras\src\main" 
tf workfold /map "$/GPA/apis/cnova-transportadoras/src/main" "C:\TFS2015\GPA\apis\cnova-transportadoras\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-transportadoras/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\viavarejo-automotivo\src\main" 
tf workfold /map "$/GPA/apis/viavarejo-automotivo/src/main" "C:\TFS2015\GPA\apis\viavarejo-automotivo\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/viavarejo-automotivo/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\apis\viavarejo-oms\src\main" 
tf workfold /map "$/GPA/apis/viavarejo-oms/src/main" "C:\TFS2015\GPA\apis\viavarejo-oms\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/viavarejo-oms/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-automacao\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-automacao/src/main" "C:\TFS2015\GPA\sistemas\cnova-automacao\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-automacao/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-automacao-alm\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-automacao-alm/src/main" "C:\TFS2015\GPA\sistemas\cnova-automacao-alm\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-automacao-alm/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-automacao-msite\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-automacao-msite/src/main" "C:\TFS2015\GPA\sistemas\cnova-automacao-msite\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-automacao-msite/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-clube-extra\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-clube-extra/src/main" "C:\TFS2015\GPA\sistemas\cnova-clube-extra\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-clube-extra/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-crawler\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-crawler/src/main" "C:\TFS2015\GPA\sistemas\cnova-crawler\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-crawler/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-jobs\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-jobs/src/main" "C:\TFS2015\GPA\sistemas\cnova-jobs\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-jobs/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-jobs\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-jobs/src/main" "C:\TFS2015\GPA\sistemas\cnova-jobs\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-jobs/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-busca\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-busca/src/main" "C:\TFS2015\GPA\sistemas\cnova-busca\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-busca/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-msite-dotnet\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-msite-dotnet/src/main" "C:\TFS2015\GPA\sistemas\cnova-msite-dotnet\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-msite-dotnet/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-lista-casamento\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-lista-casamento/src/main" "C:\TFS2015\GPA\sistemas\cnova-lista-casamento\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-lista-casamento/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-mapp\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-mapp/src/main" "C:\TFS2015\GPA\sistemas\cnova-mapp\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-mapp/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-msite\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-msite/src/main" "C:\TFS2015\GPA\sistemas\cnova-msite\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-msite/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-pricing\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-pricing/src/main" "C:\TFS2015\GPA\sistemas\cnova-pricing\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-pricing/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-sdk\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-sdk/src/main" "C:\TFS2015\GPA\sistemas\cnova-sdk\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-sdk/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\cnova-seo\src\main" 
tf workfold /map "$/GPA/sistemas/cnova-seo/src/main" "C:\TFS2015\GPA\sistemas\cnova-seo\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/cnova-seo/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\componentes\cnova-meiosdepagamento_visacheckout\src\main" 
tf workfold /map "$/GPA/sistemas/componentes/cnova-meiosdepagamento_visacheckout/src/main" "C:\TFS2015\GPA\sistemas\componentes\cnova-meiosdepagamento_visacheckout\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/componentes/cnova-meiosdepagamento_visacheckout/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\ferramentas\cnova-adminseguranca\src\main" 
tf workfold /map "$/GPA/sistemas/ferramentas/cnova-adminseguranca/src/main" "C:\TFS2015\GPA\sistemas\ferramentas\cnova-adminseguranca\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/ferramentas/cnova-adminseguranca/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\ferramentas\cnova-copymongo\src\main" 
tf workfold /map "$/GPA/sistemas/ferramentas/cnova-copymongo/src/main" "C:\TFS2015\GPA\sistemas\ferramentas\cnova-copymongo\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/ferramentas/cnova-copymongo/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\ferramentas\cnova-ge_importadorplanos\src\main" 
tf workfold /map "$/GPA/sistemas/ferramentas/cnova-ge_importadorplanos/src/main" "C:\TFS2015\GPA\sistemas\ferramentas\cnova-ge_importadorplanos\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/ferramentas/cnova-ge_importadorplanos/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\ferramentas\cnova-monitoriacatalogo\src\main" 
tf workfold /map "$/GPA/sistemas/ferramentas/cnova-monitoriacatalogo/src/main" "C:\TFS2015\GPA\sistemas\ferramentas\cnova-monitoriacatalogo\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/ferramentas/cnova-monitoriacatalogo/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\ferramentas\cnova-monitoriapaypal\src\main" 
tf workfold /map "$/GPA/sistemas/ferramentas/cnova-monitoriapaypal/src/main" "C:\TFS2015\GPA\sistemas\ferramentas\cnova-monitoriapaypal\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/ferramentas/cnova-monitoriapaypal/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\websites\cnova-adminb2b\src\main" 
tf workfold /map "$/GPA/sistemas/websites/cnova-adminb2b/src/main" "C:\TFS2015\GPA\sistemas\websites\cnova-adminb2b\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/websites/cnova-adminb2b/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\websites\cnova-apionline\src\main" 
tf workfold /map "$/GPA/sistemas/websites/cnova-apionline/src/main" "C:\TFS2015\GPA\sistemas\websites\cnova-apionline\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/websites/cnova-apionline/src/main" /recursive

del /F /S /Q "C:\TFS2015\GPA\sistemas\websites\cnova-televendas\src\main" 
tf workfold /map "$/GPA/sistemas/websites/cnova-televendas/src/main" "C:\TFS2015\GPA\sistemas\websites\cnova-televendas\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/websites/cnova-televendas/src/main" /recursive

del /F /S /Q "C:\TFS2015\sistemas\winservices-loja" 
tf workfold /map "$/GPA/sistemas/winservices-loja" "C:\TFS2015/GPA/sistemas/winservices-loja" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/winservices-loja" /recursive

del /F /S /Q "C:\TFS2015\sistemas\winservices-corp" 
tf workfold /map "$/GPA/sistemas/winservices-corp" "C:\TFS2015/GPA/sistemas/winservices-corp" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/sistemas/winservices-corp" /recursive

pause