@echo off
echo ================================================
echo    Sistema de Consulta de Estoque - PO-UI
echo ================================================
echo.

echo [1/4] Instalando dependencias...
call npm install

echo.
echo [2/4] Verificando instalacao do Angular CLI...
call ng version

echo.
echo [3/4] Compilando projeto...
call ng build

echo.
echo [4/4] Iniciando servidor de desenvolvimento...
echo.
echo Acesse: http://localhost:4200
echo.
echo Para parar o servidor, pressione Ctrl+C
echo.

call ng serve --open

pause
