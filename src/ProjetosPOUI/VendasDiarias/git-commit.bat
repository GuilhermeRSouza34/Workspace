@echo off
echo Configurando Git para o projeto VendasDiarias...

cd /d "C:\Users\guilh\Workspace\Workspace"

echo.
echo Verificando status do Git...
git status

echo.
echo Adicionando arquivos (ignorando node_modules e outros arquivos temporários)...
git add .

echo.
echo Status após adicionar arquivos:
git status

echo.
echo Para fazer o commit, execute:
echo git commit -m "Adiciona projeto VendasDiarias com POUI"
echo.

pause
