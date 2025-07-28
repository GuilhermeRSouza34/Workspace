# 🔧 Guia de Configuração - Conexão Frontend/Backend

## 📖 Visão Geral

Seu projeto já possui:
- ✅ **Backend TLPP**: `backend/ConsultaEstoqueAPI.prw` com API REST completa
- ✅ **Frontend Angular**: Com PO-UI e serviços configurados
- ✅ **Ferramentas de teste**: Para validar a conexão

## 🖥️ Configuração do Backend (Protheus)

### 1. Deploy do Programa TLPP

1. **Compile o programa** `ConsultaEstoqueAPI.prw` no Protheus
2. **Verifique se está ativo** no ambiente de execução

### 2. Configuração do AppServer.ini

Adicione/verifique estas configurações no arquivo `appserver.ini`:

```ini
[HTTPSERVER]
HTTPPORT=8080
ENABLECORS=1
CORSALLOWORIGIN=*
CORSALLOWHEADERS=Content-Type,Authorization,X-Requested-With,Accept
CORSALLOWMETHODS=GET,POST,PUT,DELETE,OPTIONS
ENABLESSL=0
```

### 3. Reiniciar o Serviço

Após alterar o `appserver.ini`, reinicie o serviço do Protheus.

## 🌐 Configuração do Frontend (Angular)

### 1. Verificar Ambientes

**Desenvolvimento** (`src/environments/environment.ts`):
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/rest'  // IP do seu servidor Protheus
};
```

**Produção** (`src/environments/environment.prod.ts`):
```typescript
export const environment = {
  production: true,
  apiUrl: 'http://seu-servidor-protheus:8080/rest'  // IP real do servidor
};
```

### 2. Instalar Dependências

```bash
npm install
```

### 3. Executar a Aplicação

```bash
# Modo desenvolvimento
npm start
# ou
ng serve

# A aplicação estará disponível em http://localhost:4200
```

## 🧪 Testando a Conexão

### Método 1: Arquivo de Teste Automatizado
Execute o arquivo `testar-api.bat`:
```cmd
./testar-api.bat
```

### Método 2: Teste via Navegador
Abra o arquivo `teste-api.html` no navegador e execute os testes.

### Método 3: Teste Manual via cURL
```bash
# Teste básico de conectividade
curl http://localhost:8080/rest/locais-estoque

# Teste de consulta
curl "http://localhost:8080/rest/consulta-estoque?codigoProduto="
```

### Método 4: Teste Direto no Angular
Acesse `http://localhost:4200` e use a interface da aplicação.

## 🔍 Endpoints da API

Sua API expõe os seguintes endpoints:

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/rest/consulta-estoque` | Consulta estoque com filtros |
| GET | `/rest/locais-estoque` | Lista locais de estoque |
| GET | `/rest/categorias-estoque` | Lista categorias |
| GET | `/rest/produto-estoque/{codigo}` | Produto específico |

### Parâmetros de Consulta

Para `/rest/consulta-estoque`:
- `codigoProduto`: Código ou parte do código
- `descricaoProduto`: Descrição ou parte da descrição
- `categoria`: Código da categoria/grupo
- `local`: Código do local de estoque
- `somenteComSaldo`: true/false

## 🚨 Resolução de Problemas

### Erro de CORS
Se aparecer erro de CORS no console do navegador:
1. Verifique se `ENABLECORS=1` está no appserver.ini
2. Reinicie o serviço do Protheus
3. Verifique se a porta está correta

### Erro 404 - Endpoint não encontrado
1. Verifique se o programa foi compilado corretamente
2. Confirme se o endpoint está ativo no Protheus
3. Teste com ferramentas como Postman ou cURL

### Erro de Conexão
1. Verifique se o serviço do Protheus está rodando
2. Confirme o IP e porta do servidor
3. Teste a conectividade de rede

### Erro 500 - Erro Interno
1. Verifique os logs do Protheus
2. Confirme se as tabelas SB1, SB2, SBM, NNR existem
3. Verifique permissões de acesso às tabelas

## 📊 Monitoramento

### Logs do Protheus
Monitore os logs do Protheus para identificar possíveis erros:
- Console do AppServer
- Logs de REST API
- Logs de SQL (se habilitado)

### Console do Navegador
No frontend, abra o console do navegador (F12) para verificar:
- Erros de JavaScript
- Requests HTTP falhando
- Respostas da API

## 🔧 Configurações Avançadas

### Proxy para Desenvolvimento
Se necessário, configure um proxy no `angular.json`:

```json
"serve": {
  "builder": "@angular-devkit/build-angular:dev-server",
  "options": {
    "proxyConfig": "proxy.conf.json"
  }
}
```

Crie `proxy.conf.json`:
```json
{
  "/rest/*": {
    "target": "http://localhost:8080",
    "secure": false,
    "changeOrigin": true,
    "logLevel": "debug"
  }
}
```

### Configuração de Timeout
Ajuste timeouts se necessário no service:

```typescript
return this.http.get<ProdutoEstoque[]>(`${this.apiUrl}/consulta-estoque`, { 
  params,
  timeout: 30000 // 30 segundos
});
```

## ✅ Checklist Final

- [ ] Programa TLPP compilado e ativo
- [ ] AppServer.ini configurado com CORS
- [ ] Serviço Protheus reiniciado
- [ ] Dependências npm instaladas
- [ ] Ambiente Angular configurado
- [ ] Testes de conectividade executados
- [ ] Aplicação Angular rodando
- [ ] Conexão frontend/backend funcionando

## 📞 Suporte

Se ainda houver problemas:
1. Execute os testes automatizados primeiro
2. Verifique logs do Protheus e console do navegador
3. Confirme configurações de rede e firewall
4. Teste endpoints individualmente com ferramentas externas
