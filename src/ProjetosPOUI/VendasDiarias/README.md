# 📊 Sistema de Vendas Diárias - PO-UI

Sistema moderno para consulta de vendas diárias desenvolvido com **Angular + PO-UI** no frontend e **TLPP** no backend, integrado ao **Protheus**.

## 🚀 Funcionalidades

### 📈 Dashboard Principal
- **Consulta por período** (mês/ano)
- **Totalizadores** em tempo real
- **Métricas visuais** com cards interativos
- **Tabela detalhada** com todos os dados

### 📊 Tipos de Movimentação
- ✅ **Vendas** (Pedidos SC5/SC6)
- 📦 **Remessas** 
- 💰 **Fatura Tudo**
- ↩️ **Devoluções** (todas as modalidades)
- 🔄 **Transferências** entre filiais

### 🔧 Recursos Avançados
- 📤 **Exportação para Excel**
- 🔍 **Filtros dinâmicos**
- 📱 **Design responsivo**
- ⚡ **Performance otimizada**
- 🔄 **Atualização em tempo real**

## 🏗️ Arquitetura

```
VendasDiarias/
├── 🎨 Frontend (Angular + PO-UI)
│   ├── src/app/
│   │   ├── vendas-diarias/          # Componente principal
│   │   ├── services/                # Serviços de integração
│   │   └── environments/            # Configurações
│   └── assets/                      # Recursos estáticos
├── 🔧 Backend (TLPP)
│   └── VendasDiariasAPI.tlpp       # API REST
└── 📚 Docs/
    └── README.md                    # Este arquivo
```

## 🔧 Instalação e Configuração

### 1. **Pré-requisitos**
```bash
# Node.js v16+ e npm
node --version
npm --version

# Angular CLI
npm install -g @angular/cli

# Protheus com TLPP habilitado
```

### 2. **Instalação das Dependências**
```bash
# Na pasta do projeto
cd VendasDiarias
npm install
```

### 3. **Configuração do Backend**

#### Compilar API TLPP no Protheus:
```advpl
// Compilar: VendasDiariasAPI.tlpp
// Configurar: RESTFUL endpoints no Protheus
```

#### Configurar CORS no Protheus:
```ini
[WEBSERVER]
CORS=ON
CORSALLOWORIGIN=*
CORSALLOWMETHODS=GET,POST,PUT,DELETE,OPTIONS
CORSALLOWHEADERS=Content-Type,Authorization
```

### 4. **Configuração do Frontend**

#### Atualizar URL da API:
```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://seu-servidor-protheus:porta/rest',
  // ...
};
```

### 5. **Executar o Sistema**

#### Desenvolvimento:
```bash
npm start
# ou
ng serve

# Acesse: http://localhost:4200
```

#### Produção:
```bash
npm run build:prod
# Deploy na pasta: dist/vendas-diarias
```

## 📡 API Endpoints

### **Consultar Vendas Diárias**
```http
GET /vendas-diarias?mes=07&ano=2025
```

**Resposta:**
```json
{
  "success": true,
  "message": "Dados obtidos com sucesso",
  "periodo": "07/2025",
  "data": [
    {
      "dia": 1,
      "qtdeVendida": 1250.50,
      "vlrVendido": 35420.80,
      "qtdeRemessa": 200.00,
      "vlrRemessa": 5600.00,
      // ... outros campos
    }
  ],
  "totalRegistros": 31
}
```

### **Buscar Totalizadores**
```http
GET /vendas-diarias/totalizadores?mes=07&ano=2025
```

### **Exportar Dados**
```http
GET /vendas-diarias/export?mes=07&ano=2025&formato=excel
```

## 🎨 Interface PO-UI

### **Componentes Utilizados**
- `po-page` - Layout principal
- `po-toolbar` - Barra superior
- `po-container` - Container responsivo
- `po-table` - Tabela de dados
- `po-select` - Seleção de mês
- `po-number` - Campo de ano
- `po-button` - Botões de ação
- `po-loading` - Indicador de carregamento
- `po-widget` - Cards informativos
- `po-notification` - Notificações

### **Design System**
- 🎨 **Cores:** Palette moderna e profissional
- 📱 **Responsivo:** Mobile-first design
- ♿ **Acessibilidade:** WCAG 2.1 AA compliant
- 🌙 **Tema:** Suporte a dark/light mode

## 📊 Funcionalidades Detalhadas

### **1. Filtros Inteligentes**
- Validação automática de período
- Defaults inteligentes (mês/ano atual)
- Feedback visual de erros

### **2. Visualização de Dados**
```typescript
// Métricas calculadas automaticamente
totalEntregueQtd = vendas + transferências + remessas - devoluções
totalVendidoVlr = vendas + faturaTudo - devoluções
```

### **3. Exportação Avançada**
- Formato Excel (.xlsx)
- Nome de arquivo com timestamp
- Incluindo totalizadores
- Formatação brasileira

### **4. Tratamento de Erros**
- Retry automático
- Mensagens amigáveis
- Logs detalhados
- Fallbacks graceful

## 🔐 Segurança

### **Autenticação**
```typescript
// Integração com sessão Protheus
headers: {
  'Authorization': `Bearer ${userToken}`,
  'Content-Type': 'application/json'
}
```

### **Validações**
- Sanitização de inputs
- Validação de período
- Rate limiting
- CORS configurado

## 🚀 Performance

### **Otimizações Frontend**
- Lazy loading de componentes
- OnPush change detection
- Virtual scrolling para tabelas grandes
- Bundle splitting

### **Otimizações Backend**
- Queries indexadas
- Cache de resultados
- Compressão de resposta
- Paginação inteligente

## 🧪 Testes

### **Executar Testes**
```bash
# Testes unitários
npm test

# Testes e2e
npm run e2e

# Coverage
npm run test:coverage
```

### **Estrutura de Testes**
```
src/
├── app/
│   ├── vendas-diarias/
│   │   ├── vendas-diarias.component.spec.ts
│   │   └── ...
│   └── services/
│       └── vendas-diarias.service.spec.ts
```

## 📱 Mobile & PWA

### **Recursos Mobile**
- Design responsivo completo
- Touch-friendly interface
- Offline capability (service worker)
- App-like experience

### **PWA Features**
```json
// manifest.json
{
  "name": "Vendas Diárias",
  "short_name": "VendasDiarias",
  "theme_color": "#2c3e50",
  "background_color": "#ffffff",
  "display": "standalone",
  "start_url": "/"
}
```

## 🛠️ Desenvolvimento

### **Scripts Disponíveis**
```bash
npm start           # Desenvolvimento
npm run build       # Build produção
npm run test        # Testes unitários
npm run lint        # Linting
npm run e2e         # Testes e2e
npm run analyze     # Análise de bundle
```

### **Estrutura de Pastas**
```
src/
├── app/
│   ├── vendas-diarias/     # Feature principal
│   ├── shared/             # Componentes compartilhados
│   ├── services/           # Serviços
│   └── models/             # Interfaces/Types
├── assets/                 # Recursos estáticos
├── environments/           # Configurações
└── styles/                 # Estilos globais
```

## 🤝 Contribuição

### **Como Contribuir**
1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### **Padrões de Código**
- ESLint + Prettier configurados
- Conventional Commits
- Tests obrigatórios
- Code review process

## 📞 Suporte

### **Documentação**
- [PO-UI Documentation](https://po-ui.io/)
- [Angular Documentation](https://angular.io/)
- [TLPP Documentation](https://tdn.totvs.com/pages/viewpage.action?pageId=6063090)

### **Issues & Bugs**
- Criar issue no repositório
- Incluir logs e steps to reproduce
- Especificar versão do Protheus

---

## 🎯 Próximos Passos

### **Roadmap v2.0**
- [ ] Dashboard com gráficos interativos
- [ ] Filtros avançados (vendedor, cliente, produto)
- [ ] Comparativo entre períodos
- [ ] Alertas automáticos
- [ ] API de notificações
- [ ] Integração com WhatsApp/Email

### **Melhorias Técnicas**
- [ ] Implementar GraphQL
- [ ] Adicionar testes e2e
- [ ] CI/CD pipeline
- [ ] Docker containers
- [ ] Monitoramento de performance

---

**Desenvolvido com ❤️ usando Angular + PO-UI + TLPP**

*Sistema criado para modernizar relatórios ADVPL tradicionais com tecnologias web modernas.*
