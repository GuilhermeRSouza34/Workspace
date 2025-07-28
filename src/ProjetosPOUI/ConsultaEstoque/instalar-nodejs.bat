@echo off
echo ========================================
echo   INSTALACAO DO NODE.JS
echo   Sistema de Consulta de Estoque
echo ========================================
echo.

echo Verificando se o Node.js ja esta instalado...
node --version >nul 2>&1
if not errorlevel 1 (
    echo ✅ Node.js ja esta instalado!
    node --version
    npm --version
    goto :continuar
)

echo ⚠️  Node.js nao encontrado. Iniciando instalacao...
echo.

echo Opcoes de instalacao:
echo.
echo [1] Download manual (recomendado)
echo [2] Instalacao via Chocolatey (se disponivel)
echo [3] Pular instalacao
echo.

set /p opcao="Digite sua opcao (1-3): "

if "%opcao%"=="1" goto :manual
if "%opcao%"=="2" goto :chocolatey
if "%opcao%"=="3" goto :pular
goto :manual

:manual
echo.
echo ========================================
echo   DOWNLOAD MANUAL DO NODE.JS
echo ========================================
echo.
echo 1. Abra o navegador em: https://nodejs.org/
echo 2. Baixe a versao LTS (recomendada)
echo 3. Execute o instalador
echo 4. Reinicie este script
echo.
echo Abrindo o site do Node.js...
start https://nodejs.org/
echo.
echo Apos a instalacao, feche este terminal e abra um novo,
echo depois execute novamente: verificar-e-executar.bat
echo.
pause
goto :fim

:chocolatey
echo.
echo Tentando instalar via Chocolatey...
choco --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Chocolatey nao encontrado
    echo Instalando Chocolatey primeiro...
    
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    
    if errorlevel 1 (
        echo ❌ Erro ao instalar Chocolatey
        goto :manual
    )
)

echo Instalando Node.js via Chocolatey...
choco install nodejs -y

if errorlevel 1 (
    echo ❌ Erro na instalacao via Chocolatey
    goto :manual
) else (
    echo ✅ Node.js instalado via Chocolatey
    echo Reinicie o terminal e execute: verificar-e-executar.bat
    pause
    goto :fim
)

:pular
echo.
echo ⚠️  Pulando instalacao do Node.js
echo.
echo IMPORTANTE: Para usar o sistema voce precisa:
echo 1. Instalar Node.js manualmente: https://nodejs.org/
echo 2. Reiniciar o terminal
echo 3. Executar: verificar-e-executar.bat
echo.
pause
goto :fim

:continuar
echo.
echo ✅ Node.js detectado! Continuando com a verificacao...
echo.
pause
call verificar-e-executar.bat
goto :fim

:fim
echo.
echo Script de instalacao finalizado.
pause
