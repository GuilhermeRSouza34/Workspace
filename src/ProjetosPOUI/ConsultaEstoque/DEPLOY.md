# Configuração de Ambientes

## Desenvolvimento (environment.ts)
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/rest'  // Servidor local
};
```

## Produção (environment.prod.ts)
```typescript
export const environment = {
  production: true,
  apiUrl: '/rest'  // URL relativa para produção
};
```

## Configuração do Servidor Protheus

### 1. Configurar CORS no Protheus
No arquivo appserver.ini, adicione:

```ini
[HTTPSERVER]
ENABLECORS=1
CORSALLOWORIGIN=*
CORSALLOWHEADERS=Content-Type,Authorization
CORSALLOWMETHODS=GET,POST,PUT,DELETE,OPTIONS
```

### 2. Configurar Porta REST
```ini
[HTTPSERVER]
HTTPPORT=8080
```

### 3. Reiniciar o serviço do Protheus após as alterações

## Deployment

### Frontend (Angular)
```bash
# Build para produção
ng build --prod

# Os arquivos gerados estarão em dist/consulta-estoque/
# Copie estes arquivos para seu servidor web (IIS, Apache, Nginx)
```

### Backend (Protheus)
1. Compile o arquivo ConsultaEstoqueAPI.tlpp
2. Publique no ambiente de produção
3. Configure as permissões necessárias

## Troubleshooting

### Erro de CORS
Se encontrar erro de CORS durante desenvolvimento, você pode:

1. Usar proxy do Angular CLI:
```json
// proxy.conf.json
{
  "/rest/*": {
    "target": "http://seu-servidor-protheus:8080",
    "secure": false,
    "changeOrigin": true,
    "logLevel": "debug"
  }
}
```

2. Executar com proxy:
```bash
ng serve --proxy-config proxy.conf.json
```
