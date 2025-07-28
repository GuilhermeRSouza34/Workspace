@echo off
echo ========================================
echo   CONFIGURACAO E TESTE COMPLETO
echo   Sistema de Consulta de Estoque
echo ========================================
echo.

echo [1/5] Verificando estrutura do projeto...
if exist "src\app\services\estoque.service.ts" (
    echo ✅ Frontend Angular encontrado
) else (
    echo ❌ Frontend nao encontrado
    goto :erro
)

if exist "backend\ConsultaEstoqueAPI.prw" (
    echo ✅ Backend TLPP encontrado
) else (
    echo ❌ Backend nao encontrado
    goto :erro
)

echo.
echo [2/5] Verificando dependencias npm...
if exist "node_modules" (
    echo ✅ Node modules instalados
) else (
    echo ⚠️  Instalando dependencias...
    npm install
    if errorlevel 1 (
        echo ❌ Erro ao instalar dependencias
        goto :erro
    )
)

echo.
echo [3/5] Configurando ambiente...
set /p servidor="Digite o IP do servidor Protheus (padrao: localhost): "
set /p porta="Digite a porta REST (padrao: 8080): "

if "%servidor%"=="" set servidor=localhost
if "%porta%"=="" set porta=8080

echo.
echo Configuracao:
echo - Servidor: %servidor%
echo - Porta: %porta%
echo - URL API: http://%servidor%:%porta%/rest

echo.
echo [4/5] Testando conectividade com a API...
echo Testando endpoint de locais...
curl -s -o nul -w "Status: %%{http_code}\n" http://%servidor%:%porta%/rest/locais-estoque 2>nul
if errorlevel 1 (
    echo ❌ ERRO: Nao foi possivel conectar ao servidor
    echo.
    echo CHECKLIST DE VERIFICACAO:
    echo 1. O servico do Protheus esta rodando?
    echo 2. O programa ConsultaEstoqueAPI.prw foi compilado?
    echo 3. As configuracoes de CORS estao no appserver.ini?
    echo 4. A porta %porta% esta liberada no firewall?
    echo.
    echo Para mais detalhes, consulte CONFIGURACAO-CONEXAO.md
    goto :erro
)

echo ✅ API respondendo corretamente

echo.
echo [5/5] Iniciando aplicacao Angular...
echo A aplicacao sera aberta em http://localhost:4200
echo Pressione Ctrl+C para parar o servidor
echo.

start "Browser" http://localhost:4200
npm start

goto :fim

:erro
echo.
echo ❌ Configuracao nao concluida
echo Consulte o arquivo CONFIGURACAO-CONEXAO.md para instrucoes detalhadas
echo.
pause
exit /b 1

:fim
echo.
echo ✅ Aplicacao finalizada
pause
