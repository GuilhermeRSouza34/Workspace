# Projeto Vendas Diárias - POUI

Este projeto transforma o relatório ADVPL `VENDDIA.prw` em uma aplicação web moderna usando Angular + PO-UI.

## Como fazer commit do projeto

### 1. Primeiro, limpe o cache do Git (se necessário)
Execute o script na raiz do workspace:
```bash
.\limpar-git-cache.bat
```

### 2. Verifique o que será commitado
```bash
cd "C:\Users\guilh\Workspace\Workspace"
git status
```

### 3. Adicione os arquivos
```bash
git add .
```

### 4. Faça o commit
```bash
git commit -m "Adiciona projeto VendasDiarias com POUI"
```

## Arquivos incluídos no commit

✅ **Incluídos:**
- Código fonte TypeScript (`src/`)
- Arquivos de configuração (`angular.json`, `tsconfig.json`, etc.)
- API TLPP (`VendasDiariasAPI.tlpp`)
- Arquivo ADVPL original (`VENDDIA.prw`)
- Scripts de inicialização (`iniciar.bat`)
- Arquivos de documentação (`README.md`)
- Arquivo `.gitignore`

❌ **Excluídos (via .gitignore):**
- `node_modules/` - Dependências do npm
- `package-lock.json` - Lock file do npm
- `.angular/` - Cache do Angular
- `dist/` - Arquivos compilados
- Arquivos de log e temporários

## Para rodar o projeto

1. Instale as dependências:
```bash
npm install
```

2. Execute o projeto:
```bash
npm start
```
ou
```bash
.\iniciar.bat
```

O projeto estará disponível em `http://localhost:4200`
