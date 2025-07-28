@echo off
echo Limpando cache do Git para aplicar .gitignore...

cd /d "C:\Users\guilh\Workspace\Workspace"

echo.
echo Removendo arquivos do cache que devem ser ignorados...

REM Remove node_modules do cache se estiver sendo rastreado
git rm -r --cached src/ProjetosPOUI/VendasDiarias/node_modules/ 2>nul
git rm -r --cached src/ProjetosPOUI/ConsultaEstoque/node_modules/ 2>nul
git rm -r --cached src/ProjetosPOUI/meu-primeiro-poui/node_modules/ 2>nul

REM Remove package-lock.json do cache
git rm --cached src/ProjetosPOUI/VendasDiarias/package-lock.json 2>nul
git rm --cached src/ProjetosPOUI/ConsultaEstoque/package-lock.json 2>nul
git rm --cached src/ProjetosPOUI/meu-primeiro-poui/package-lock.json 2>nul

REM Remove pasta .angular do cache
git rm -r --cached src/ProjetosPOUI/VendasDiarias/.angular/ 2>nul
git rm -r --cached src/ProjetosPOUI/ConsultaEstoque/.angular/ 2>nul
git rm -r --cached src/ProjetosPOUI/meu-primeiro-poui/.angular/ 2>nul

echo.
echo Verificando status após limpeza:
git status

echo.
echo Agora adicione os arquivos novamente:
echo git add .
echo git commit -m "Aplica .gitignore e remove arquivos desnecessários"

pause
