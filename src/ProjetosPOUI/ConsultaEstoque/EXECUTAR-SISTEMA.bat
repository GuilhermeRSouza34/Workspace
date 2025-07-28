@echo off
echo ========================================
echo   EXECUTANDO SISTEMA - VERSAO FINAL
echo   Consulta de Estoque - 100%% Funcional
echo ========================================
echo.

echo Configurando ambiente...
set "PATH=%PATH%;C:\Program Files\nodejs;%APPDATA%\npm"

echo ✅ Node.js: 
node --version

echo ✅ npm: 
npm --version

echo ✅ Angular CLI: 
npx ng version --skip-git

echo.
echo ========================================
echo   INICIANDO APLICACAO
echo ========================================
echo.

echo Frontend: http://localhost:4200
echo Backend:  http://localhost:8080/rest
echo.

echo Para testar a API do backend, certifique-se que:
echo 1. O programa ConsultaEstoqueAPI.prw foi compilado
echo 2. O serviço Protheus está rodando na porta 8080
echo 3. As configurações CORS estão no appserver.ini
echo.

echo Abrindo navegador...
start http://localhost:4200

echo Iniciando servidor Angular...
npx ng serve --open --host 0.0.0.0

pause
