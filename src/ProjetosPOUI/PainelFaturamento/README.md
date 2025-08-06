# 💼 Painel Inteligente de Faturamento

Sistema completo de gestão de faturamento desenvolvido com **POUI (PO-UI) + TLPP**, oferecendo uma interface moderna e responsiva para análise de dados de vendas, controle de pedidos e ranking de clientes.

## 🚀 Tecnologias Utilizadas

### Frontend
- **Angular 15** - Framework web moderno
- **PO-UI (Portal TOTVS)** - Biblioteca de componentes empresariais
- **TypeScript** - Linguagem tipada
- **SCSS** - Pré-processador CSS
- **Chart.js + ng2-charts** - Gráficos interativos

### Backend
- **TLPP (TL++)** - Linguagem de programação TOTVS
- **REST APIs** - Comunicação HTTP
- **SQL Server/Oracle** - Banco de dados Protheus
- **JSON** - Formato de dados

## 📋 Funcionalidades

### 🎯 Dashboard Principal
- **KPIs em tempo real**: Faturamento total, pedidos pendentes, clientes ativos, meta mensal
- **Gráficos interativos**: Faturamento diário, top produtos, ranking de vendedores
- **Progresso de metas**: Acompanhamento visual do desempenho mensal
- **Ações rápidas**: Navegação direta para outras funcionalidades

### 📊 Pedidos Pendentes
- **Listagem completa** com filtros avançados por data, vendedor, cliente e status
- **Atualização de status** em tempo real
- **Exportação para Excel** com dados filtrados
- **Resumo estatístico** dos pedidos pendentes

### 🏆 Ranking de Clientes
- **Classificação por faturamento** com crescimento percentual
- **Filtros por período** (mensal, trimestral, anual)
- **Análise de performance** por cliente
- **Dados de última compra** e categoria

### 📱 Design Responsivo
- **Interface adaptativa** para desktop, tablet e mobile
- **Tema personalizado** com cores da marca
- **Navegação intuitiva** com menu lateral
- **Animações suaves** para melhor UX

## 🛠️ Instalação e Configuração

### Pré-requisitos
- **Node.js 18+** e npm
- **Angular CLI 15+**
- **Servidor Protheus** configurado
- **TLPP** habilitado no ambiente

### 1. Frontend (Angular + PO-UI)

```bash
# Navegar para a pasta do frontend
cd src/ProjetosPOUI/PainelFaturamento/frontend

# Instalar dependências
npm install --legacy-peer-deps

# Configurar ambiente (editar src/environments/environment.ts)
# Alterar a URL da API para seu servidor Protheus

# Executar em modo desenvolvimento
npm run serve

# Build para produção
npm run build
```

### 2. Backend (TLPP)

```bash
# Compilar o arquivo TLPP
compile PainelFaturamento.tlpp

# Ou usando TDS VS Code:
# 1. Abrir o arquivo PainelFaturamento.tlpp
# 2. Pressionar Ctrl+F9 para compilar
# 3. Verificar se não há erros de compilação
```

### 3. Configuração do Servidor REST

```tlpp
// No Protheus, configurar o REST:
// 1. Acessar SIGACFG > Configurador > Servidor > Ambiente
// 2. Habilitar o módulo REST
// 3. Configurar porta (padrão 8080)
// 4. Definir contexto /rest
```

## 🔧 Configuração da API

### Environment Configuration
Editar `src/environments/environment.ts`:

```typescript
export const environment = {
  production: false,
  apiUrl: 'http://SEU-SERVIDOR:8080/rest', // URL do seu Protheus
  appName: 'Painel Faturamento',
  timeout: 30000,
  pageSize: 20
};
```

### Endpoints Disponíveis

#### Dashboard
```
GET /rest/faturamento/dashboard
```

#### Pedidos Pendentes
```
GET /rest/pedidos/pendentes?dataInicio=2024-01-01&dataFim=2024-12-31&vendedor=001
```

#### Ranking de Clientes
```
GET /rest/ranking/clientes?periodo=mensal
```

#### Exportação
```
GET /rest/relatorios/exportar?tipo=pedidos-pendentes&filtros={...}
```

## 🎨 Estrutura do Projeto

```
PainelFaturamento/
├── backend/
│   └── PainelFaturamento.tlpp        # Servidor REST TLPP
├── frontend/
│   ├── src/
│   │   ├── app/
│   │   │   ├── components/           # Componentes da interface
│   │   │   │   ├── dashboard/        # Dashboard principal
│   │   │   │   ├── pedidos-pendentes/# Gestão de pedidos
│   │   │   │   └── ranking-clientes/ # Ranking de clientes
│   │   │   ├── services/             # Serviços de API
│   │   │   │   └── faturamento.service.ts
│   │   │   ├── app.module.ts         # Módulo principal
│   │   │   └── app-routing.module.ts # Rotas da aplicação
│   │   ├── environments/             # Configurações de ambiente
│   │   └── styles.scss              # Estilos globais
│   ├── package.json                 # Dependências npm
│   ├── angular.json                 # Configuração Angular
│   └── tsconfig.json               # Configuração TypeScript
└── README.md                       # Este arquivo
```

## 🚀 Como Usar

### 1. Acesso ao Sistema
1. Abrir navegador em `http://localhost:4200`
2. O sistema carregará automaticamente o dashboard

### 2. Navegação
- **Dashboard**: Visão geral dos indicadores
- **Pedidos Pendentes**: Gestão detalhada de pedidos
- **Ranking Clientes**: Análise de performance de clientes

### 3. Filtros e Pesquisas
- Use os filtros disponíveis em cada tela
- Aplique intervalos de data conforme necessário
- Exporte relatórios em Excel quando necessário

## 🔒 Segurança e Autenticação

O sistema está preparado para implementar autenticação via token JWT:

```typescript
// Em faturamento.service.ts
private getToken(): string {
  return localStorage.getItem('auth_token') || '';
}
```

Para implementar autenticação completa:
1. Configurar endpoint de login no TLPP
2. Implementar interceptor HTTP para tokens
3. Criar guards de rota para proteção de páginas

## 📊 Tabelas do Protheus Utilizadas

- **SC5 (Pedidos de Venda)**: Dados principais dos pedidos
- **SC6 (Itens do Pedido)**: Detalhes dos itens
- **SA1 (Clientes)**: Informações dos clientes
- **SA3 (Vendedores)**: Dados dos vendedores
- **SB1 (Produtos)**: Informações dos produtos

## 🎯 Melhorias Futuras

### Funcionalidades Planejadas
- [ ] **Notificações em tempo real** via WebSocket
- [ ] **Dashboard de vendedores** individual
- [ ] **Previsão de vendas** com IA
- [ ] **Gestão de metas** por vendedor/região
- [ ] **Relatórios avançados** com mais filtros
- [ ] **App mobile** nativo
- [ ] **Integração com WhatsApp** para notificações

### Melhorias Técnicas
- [ ] **Testes unitários** completos
- [ ] **PWA** (Progressive Web App)
- [ ] **Cache inteligente** de dados
- [ ] **Logs estruturados** para debugging
- [ ] **Monitoramento** de performance

## 🤝 Contribuição

Para contribuir com o projeto:

1. **Fork** o repositório
2. Crie uma **branch** para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. **Commit** suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. **Push** para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um **Pull Request**

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 🆘 Suporte

Para suporte técnico:
- **Documentação**: Consulte este README
- **Issues**: Abra uma issue no GitHub
- **E-mail**: guilherme.souza@empresa.com

## 📈 Performance

### Métricas de Performance
- **Carregamento inicial**: < 3 segundos
- **Atualização de dados**: < 1 segundo
- **Exportação Excel**: < 5 segundos (até 10k registros)
- **Responsividade**: 100% mobile-friendly

### Otimizações Implementadas
- **Lazy loading** de componentes
- **Virtual scrolling** para listas grandes
- **Debounce** em filtros de pesquisa
- **Caching** de requests HTTP
- **Minificação** de assets

---

**Desenvolvido com ❤️ usando as melhores práticas de desenvolvimento TOTVS**

*Painel Inteligente de Faturamento v1.0.0*
