# 🚀 GUIA PRÁTICO - Como Aplicar no Seu Ambiente Protheus

## 📋 Pré-requisitos

### ✅ Verificar no seu Protheus:
```
□ Versão: Protheus 12.1.33 ou superior
□ TLPP: Habilitado e funcionando
□ REST: Servidor REST ativo
□ Tabelas: Acesso a SB1 (Produtos) e SB2 (Saldos)
□ Porta: 8080 ou similar disponível
```

### ✅ Verificar no seu PC:
```
□ Node.js 16+ instalado
□ Angular CLI 14+ instalado
□ Editor de código (VS Code recomendado)
□ Acesso de rede ao servidor Protheus
```

## 🔧 PASSO 1: Configurar o Protheus

### 1.1 Editar appserver.ini
Localize seu arquivo `appserver.ini` e adicione/modifique:

```ini
[HTTPSERVER]
HTTPPORT=8080
ENABLECORS=1
CORSALLOWORIGIN=*
CORSALLOWHEADERS=Content-Type,Authorization,X-Requested-With,Accept
CORSALLOWMETHODS=GET,POST,PUT,DELETE,OPTIONS
ENABLESSL=0
MAXCONNS=1000
```

### 1.2 Reiniciar o AppServer
```batch
# Windows - Execute como Administrador
net stop "Protheus Server - [SEU_AMBIENTE]"
net start "Protheus Server - [SEU_AMBIENTE]"

# Ou pare/inicie pelo serviços do Windows
```

### 1.3 Verificar se o REST está funcionando
Abra o navegador e teste:
```
http://SEU-SERVIDOR:8080/
```
Deve retornar algo como: `{"message":"REST Server Running"}`

## 📝 PASSO 2: Instalar o Backend (TLPP)

### 2.1 Abrir TDS (Totvs Development Studio)

### 2.2 Importar o arquivo TLPP
```
1. Menu File → Import → File System
2. Selecione: ConsultaEstoqueAPI.tlpp
3. Escolha o projeto/workspace desejado
```

### 2.3 Compilar e Aplicar
```
1. Botão direito no arquivo → Compile
2. Escolha o servidor/ambiente
3. Aguarde compilação concluir
4. Verificar se não há erros
```

### 2.4 Testar a API
No navegador, teste os endpoints:
```
http://SEU-SERVIDOR:8080/rest/locais-estoque
http://SEU-SERVIDOR:8080/rest/categorias-estoque
http://SEU-SERVIDOR:8080/rest/consulta-estoque
```

## 💻 PASSO 3: Configurar o Frontend

### 3.1 Instalar Dependências
Abra o terminal/prompt na pasta do projeto:
```batch
cd "c:\Users\Guilherme Souza\WorkspacePe\Workspace\src\ProjetosPOUI\ConsultaEstoque"
npm install
```

### 3.2 Configurar URL do Servidor
Edite o arquivo: `src\environments\environment.ts`
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://SEU-SERVIDOR-PROTHEUS:8080/rest'
};
```

**Exemplos:**
```typescript
// Servidor local
apiUrl: 'http://localhost:8080/rest'

// Servidor na rede
apiUrl: 'http://192.168.1.100:8080/rest'

// Servidor com nome
apiUrl: 'http://servidor-protheus:8080/rest'
```

### 3.3 Executar a Aplicação
```batch
npm start
```

Ou se preferir:
```batch
ng serve --open
```

## 🧪 PASSO 4: Testar Tudo Funcionando

### 4.1 Verificar Carregamento Inicial
```
✅ Aplicação abre em http://localhost:4200
✅ Dropdowns de Local e Categoria são populados
✅ Não há erros no console do navegador (F12)
```

### 4.2 Testar Consulta Simples
```
1. Deixe todos os filtros vazios
2. Clique em "Consultar"
3. Deve retornar alguns produtos
4. Verificar se os dados estão corretos
```

### 4.3 Testar Filtros
```
1. Digite parte de um código de produto conhecido
2. Clique "Consultar"
3. Verificar se retorna apenas produtos relacionados
```

## 🚨 Resolução de Problemas

### ❌ Erro: "CORS policy"
**Causa**: Configuração de CORS incorreta
**Solução**: 
```ini
# Verificar no appserver.ini:
[HTTPSERVER]
ENABLECORS=1
CORSALLOWORIGIN=*
```

### ❌ Erro: "Failed to load resource: net::ERR_CONNECTION_REFUSED"
**Causa**: Protheus não está rodando ou porta errada
**Solução**: 
```
1. Verificar se o AppServer está rodando
2. Verificar porta no appserver.ini
3. Testar acesso direto: http://servidor:porta
```

### ❌ Erro: "Cannot find module"
**Causa**: Dependências não instaladas
**Solução**: 
```bash
rm -rf node_modules
npm install
```

### ❌ Dropdown vazios (Local/Categoria)
**Causa**: API não está retornando dados
**Verificar**: 
```
1. Testar URL diretamente no navegador
2. Verificar logs do Protheus
3. Verificar permissões de acesso às tabelas
```

### ❌ Tabela vazia mesmo com filtros
**Causa**: Query não encontra dados ou erro SQL
**Verificar**: 
```
1. Dados existem nas tabelas SB1/SB2?
2. Logs do Protheus para erros SQL
3. Testar consulta manual no banco
```

## 📊 Validar Dados de Teste

### Verificar Tabelas no Protheus:
```sql
-- Verificar produtos
SELECT TOP 10 B1_COD, B1_DESC, B1_CATEG 
FROM SB1010 
WHERE D_E_L_E_T_ = ' '

-- Verificar saldos  
SELECT TOP 10 B2_COD, B2_LOCAL, B2_QATU 
FROM SB2010 
WHERE D_E_L_E_T_ = ' ' AND B2_QATU > 0
```

## 🎯 Customizações Rápidas

### Adicionar Novo Campo na Consulta:

**1. No Backend (TLPP):**
```advpl
// Adicionar na query
cQuery += ", B1_NOVO_CAMPO "

// Adicionar na formação do JSON
oProduto["novoCampo"] := AllTrim((cAlias)->B1_NOVO_CAMPO)
```

**2. No Frontend (TypeScript):**
```typescript
// Adicionar na interface
export interface ProdutoEstoque {
  // ... campos existentes
  novoCampo: string;
}

// Adicionar na tabela
readonly columns: PoTableColumn[] = [
  // ... colunas existentes
  { property: 'novoCampo', label: 'Novo Campo', width: '10%' }
];
```

### Modificar Filtros:

**Adicionar novo filtro no formulário:**
```html
<po-input
  name="novoFiltro"
  p-label="Novo Filtro"
  formControlName="novoFiltro">
</po-input>
```

## ✅ Checklist Final

Antes de colocar em produção:

```
□ Backend compilado e funcionando
□ Endpoints testados individualmente  
□ Frontend conectando corretamente
□ Dados sendo exibidos corretamente
□ Filtros funcionando como esperado
□ Performance aceitável (< 3 segundos)
□ Tratamento de erros funcionando
□ Documentação atualizada
□ Usuários treinados
```

## 📞 Suporte

Se ainda tiver problemas:

1. **Verificar logs** do AppServer Protheus
2. **Usar F12** no navegador para ver erros JavaScript
3. **Testar APIs** individualmente no Postman/Insomnia
4. **Verificar conectividade** de rede entre cliente e servidor

## 🎉 Pronto!

Seguindo este guia, você deve ter o sistema funcionando perfeitamente no seu ambiente Protheus!

**URLs importantes:**
- Frontend: http://localhost:4200
- API Backend: http://seu-servidor:8080/rest/
- Logs Protheus: Console do AppServer
