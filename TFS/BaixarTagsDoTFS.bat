rem abrir o developer command prompt for VS2015

@echo off

cd C:\TFS\GPA\Branches\v3.0-GPA
tf workfold /map "$/GPA/apis/cnova-alm/src/main" "C:\TFS\GPA\apis\cnova-alm\src\main" /collection:http://tfsserver2013:8080/tfs/Nova.com
tf get "$/GPA/apis/cnova-alm/src/main" /recursive

pause