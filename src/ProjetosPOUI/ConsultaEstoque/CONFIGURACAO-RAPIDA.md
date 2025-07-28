# Configuração de Ambientes - Sistema de Consulta de Estoque

## 🔧 Configurações Rápidas

### Desenvolvimento Local
```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/rest'
};
```

### Servidor Interno
```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://192.168.1.100:8080/rest'  // IP do servidor Protheus
};
```

### Produção
```typescript
// src/environments/environment.prod.ts
export const environment = {
  production: true,
  apiUrl: '/rest'  // URL relativa
};
```

## 🖥️ Configuração do Protheus (AppServer.ini)

```ini
[HTTPSERVER]
HTTPPORT=8080
ENABLECORS=1
CORSALLOWORIGIN=*
CORSALLOWHEADERS=Content-Type,Authorization,X-Requested-With,Accept
CORSALLOWMETHODS=GET,POST,PUT,DELETE,OPTIONS
ENABLESSL=0
```

## 📋 Checklist de Configuração

### Backend (Protheus)
- [ ] Programa `ConsultaEstoqueAPI.prw` compilado
- [ ] Configurações CORS no `appserver.ini`
- [ ] Porta 8080 liberada no firewall
- [ ] Serviço Protheus reiniciado
- [ ] Teste de conectividade: `curl http://localhost:8080/rest/locais-estoque`

### Frontend (Angular)
- [ ] Dependências instaladas: `npm install`
- [ ] Ambiente configurado corretamente
- [ ] Aplicação rodando: `npm start`
- [ ] Console do navegador sem erros de CORS

## 🧪 Scripts de Teste

### Teste Rápido da API
```bash
# Windows
.\testar-api.bat

# Manual
curl http://localhost:8080/rest/locais-estoque
```

### Teste Completo
```bash
# Windows
.\configurar-e-executar.bat
```

## 🔍 Troubleshooting

### Erro: "Access to fetch blocked by CORS policy"
1. Verifique `ENABLECORS=1` no appserver.ini
2. Reinicie o serviço Protheus
3. Confirme que `CORSALLOWORIGIN=*` está configurado

### Erro: "Connection refused"
1. Verifique se o serviço Protheus está rodando
2. Confirme a porta no appserver.ini
3. Teste conectividade: `telnet localhost 8080`

### Erro: "404 Not Found"
1. Verifique se o programa foi compilado
2. Confirme se está no ambiente correto
3. Teste outros endpoints

## 📊 URLs da Aplicação

- **Frontend**: http://localhost:4200
- **API Base**: http://localhost:8080/rest
- **Teste HTML**: Abra `teste-api.html` no navegador
