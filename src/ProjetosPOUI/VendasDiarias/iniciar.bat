@echo off
echo ======================================
echo    Sistema de Vendas Diarias - POUI
echo ======================================
echo.
echo Iniciando servidor de desenvolvimento...
echo.

cd /d "%~dp0"

echo Verificando dependencias...
if not exist "node_modules" (
    echo Instalando dependencias...
    npm install
)

echo.
echo Iniciando aplicacao Angular...
echo Acesse: http://localhost:4200
echo.
echo Pressione Ctrl+C para parar o servidor
echo.

start "" "http://localhost:4200"
npm start

pause
