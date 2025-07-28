# 🚀 Sistema de Consulta de Estoque - Guia Completo

## 📋 Resumo do Projeto

Você possui um sistema completo de consulta de estoque com:

- ✅ **Backend TLPP (AdvPL)**: API REST no arquivo `backend/ConsultaEstoqueAPI.prw`
- ✅ **Frontend Angular + PO-UI**: Interface web moderna
- ✅ **Ferramentas de teste**: Scripts automatizados para validação
- ✅ **Configuração CORS**: Para comunicação entre frontend/backend

## 🎯 Como Fazer a Conexão Funcionar

### 1️⃣ PRIMEIRO: Configure o Backend (Protheus)

#### Compile o Programa TLPP
1. Abra o **TDS Eclipse** ou **VS Code com extensão AdvPL**
2. Compile o arquivo `backend/ConsultaEstoqueAPI.prw`
3. Certifique-se que foi enviado para o servidor

#### Configure o AppServer.ini
Localize o arquivo `appserver.ini` do seu Protheus e adicione/verifique:

```ini
[HTTPSERVER]
HTTPPORT=8080
ENABLECORS=1
CORSALLOWORIGIN=*
CORSALLOWHEADERS=Content-Type,Authorization,X-Requested-With,Accept
CORSALLOWMETHODS=GET,POST,PUT,DELETE,OPTIONS
ENABLESSL=0
```

#### Reinicie o Serviço
Após alterar o `appserver.ini`, reinicie o serviço do Protheus.

### 2️⃣ SEGUNDO: Teste a API

Execute o teste automático:
```cmd
.\testar-api.bat
```

Ou teste manualmente:
```cmd
curl http://localhost:8080/rest/locais-estoque
```

**Resultado esperado**: Retorno JSON com dados ou array vazio (não erro).

### 3️⃣ TERCEIRO: Configure o Frontend

#### Instale as Dependências
```cmd
npm install
```

#### Verifique o Ambiente
No arquivo `src/environments/environment.ts`, confirme:
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/rest'  // IP do seu servidor Protheus
};
```

### 4️⃣ QUARTO: Execute a Aplicação

Use o script automatizado:
```cmd
.\configurar-e-executar.bat
```

Ou execute manualmente:
```cmd
npm start
```

A aplicação ficará disponível em: **http://localhost:4200**

## 🔍 Endpoints da API

Sua API expõe 4 endpoints principais:

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/rest/consulta-estoque` | GET | Consulta estoque com filtros |
| `/rest/locais-estoque` | GET | Lista todos os locais |
| `/rest/categorias-estoque` | GET | Lista todas as categorias |
| `/rest/produto-estoque/{codigo}` | GET | Busca produto específico |

### Exemplo de Uso:
```
http://localhost:8080/rest/consulta-estoque?codigoProduto=001&somenteComSaldo=true
```

## 🚨 Resolução de Problemas

### ❌ Erro: "Access to fetch blocked by CORS policy"
**Solução:**
1. Verifique se `ENABLECORS=1` está no appserver.ini
2. Reinicie o serviço Protheus
3. Teste a API diretamente no navegador

### ❌ Erro: "Connection refused" ou "ERR_CONNECTION_REFUSED"
**Solução:**
1. Verifique se o serviço Protheus está rodando
2. Confirme a porta 8080 no appserver.ini
3. Teste: `telnet localhost 8080`

### ❌ Erro: "404 Not Found"
**Solução:**
1. Verifique se o programa foi compilado corretamente
2. Confirme se está no ambiente correto
3. Execute o programa manualmente no Protheus

### ❌ Frontend carrega mas não traz dados
**Solução:**
1. Abra as ferramentas de desenvolvedor (F12)
2. Vá na aba "Console" para ver erros
3. Vá na aba "Network" para ver as requisições HTTP

## 📊 Estrutura dos Dados

### Consulta de Estoque (Resposta):
```json
[
  {
    "codigo": "001",
    "descricao": "PRODUTO TESTE",
    "categoria": "01",
    "unidade": "UN",
    "local": "01",
    "saldoAtual": 100,
    "saldoDisponivel": 90,
    "saldoReservado": 10,
    "custoMedio": 15.50,
    "precoVenda": 25.00,
    "ultimaMovimentacao": "2025-01-15",
    "ativo": true
  }
]
```

## 🛠️ Ferramentas de Desenvolvimento

### Teste da API
- `testar-api.bat`: Teste automático via curl
- `teste-api.html`: Interface web para testes
- Postman/Insomnia: Para testes avançados

### Logs e Debug
- **Console do navegador (F12)**: Erros JavaScript e requests
- **Logs do Protheus**: Erros do backend
- **Network tab (F12)**: Status das requisições HTTP

## 📁 Arquivos Importantes

```
ConsultaEstoque/
├── backend/
│   └── ConsultaEstoqueAPI.prw          # ✅ Sua API REST
├── src/environments/
│   ├── environment.ts                  # 🔧 URL da API (dev)
│   └── environment.prod.ts             # 🔧 URL da API (prod)
├── src/app/services/
│   └── estoque.service.ts              # 🔗 Conecta com a API
├── configurar-e-executar.bat           # 🚀 Script completo
├── testar-api.bat                      # 🧪 Teste rápido
└── teste-api.html                      # 🌐 Teste via browser
```

## ✅ Checklist Final

Antes de pedir ajuda, verifique:

- [ ] Programa TLPP compilado e ativo
- [ ] AppServer.ini configurado com CORS
- [ ] Serviço Protheus reiniciado
- [ ] Teste `curl http://localhost:8080/rest/locais-estoque` funciona
- [ ] `npm install` executado sem erros
- [ ] Frontend roda com `npm start`
- [ ] Não há erros no console do navegador (F12)

## 🆘 Precisa de Ajuda?

Se mesmo seguindo este guia você ainda tiver problemas:

1. **Execute os testes primeiro**: `.\testar-api.bat`
2. **Capture prints dos erros**: Console do navegador + terminal
3. **Verifique os logs**: Do Protheus e do Angular
4. **Teste isoladamente**: API primeiro, depois frontend

---

**💡 Dica:** Seu backend já está pronto e bem estruturado! O problema mais comum é configuração de CORS ou porta incorreta.
