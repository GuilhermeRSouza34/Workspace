@echo off
echo ========================================
echo   EXECUTANDO FRONTEND - AGORA!
echo ========================================
echo.

echo Configurando ambiente...
set "PATH=%PATH%;C:\Program Files\nodejs;%APPDATA%\npm"

echo Navegando para o projeto...
cd /d "c:\Users\Guilherme Souza\WorkspacePe\Workspace\src\ProjetosPOUI\ConsultaEstoque"

echo Verificando se Node.js esta disponivel...
node --version
if errorlevel 1 (
    echo Erro: Node.js nao encontrado
    pause
    exit /b 1
)

echo.
echo ========================================
echo   INICIANDO APLICACAO ANGULAR
echo ========================================
echo.

echo Abrindo navegador em http://localhost:4200
start http://localhost:4200

echo.
echo Iniciando servidor de desenvolvimento...
echo Aguarde a mensagem: "Local: http://localhost:4200"
echo.

npx ng serve --host 0.0.0.0 --port 4200

echo.
echo Servidor encerrado.
pause
