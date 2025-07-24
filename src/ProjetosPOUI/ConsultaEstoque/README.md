# Sistema de Consulta de Estoque - PO-UI + Protheus

Este projeto implementa uma consulta de estoque usando PO-UI (Angular) no frontend e Protheus (TLPP) no backend.

## 📋 Funcionalidades

- ✅ Consulta de estoque com múltiplos filtros
- ✅ Visualização em tabela responsiva
- ✅ Filtros por código, descrição, categoria e local
- ✅ Opção para visualizar apenas produtos com saldo
- ✅ Resumo estatístico do estoque consultado
- ✅ Integração via API REST com Protheus
- ✅ Interface moderna usando componentes PO-UI

## 🛠️ Tecnologias Utilizadas

### Frontend (PO-UI)
- Angular 14+
- PO-UI Components
- TypeScript
- Bootstrap (via PO-UI)
- RxJS

### Backend (Protheus)
- TLPP (Totvs Language++)
- API REST
- Banco de dados Protheus (SB1/SB2)

## 📁 Estrutura do Projeto

```
ConsultaEstoque/
├── src/
│   ├── app/
│   │   ├── consulta-estoque/          # Componente principal
│   │   ├── models/                    # Interfaces TypeScript
│   │   ├── services/                  # Serviços Angular
│   │   ├── app.component.*           # Componente raiz
│   │   ├── app.module.ts             # Módulo principal
│   │   └── app-routing.module.ts     # Configuração de rotas
│   ├── environments/                  # Configurações de ambiente
│   ├── index.html                    # Página principal
│   ├── main.ts                       # Bootstrap da aplicação
│   └── styles.css                    # Estilos globais
├── angular.json                      # Configuração Angular CLI
├── package.json                      # Dependências npm
└── README.md                         # Este arquivo
```

## 🚀 Como Executar

### Pré-requisitos

1. Node.js 14+ instalado
2. Angular CLI instalado: `npm install -g @angular/cli`
3. Protheus com módulo REST habilitado
4. Banco de dados Protheus configurado

### Frontend (PO-UI)

1. Navegue até a pasta do projeto:
```bash
cd src/ProjetosPOUI/ConsultaEstoque
```

2. Instale as dependências:
```bash
npm install
```

3. Configure o ambiente em `src/environments/environment.ts`:
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://seu-servidor-protheus:porta/rest'
};
```

4. Execute o projeto:
```bash
npm start
```

5. Acesse http://localhost:4200

### Backend (Protheus)

1. Compile e publique o arquivo `ConsultaEstoqueAPI.tlpp` no Protheus
2. Configure o serviço REST no Protheus
3. Certifique-se de que as tabelas SB1 e SB2 estão acessíveis

## 📊 Funcionalidades Detalhadas

### Filtros Disponíveis

- **Código do Produto**: Busca por código exato ou parcial
- **Descrição do Produto**: Busca por texto na descrição
- **Categoria**: Filtro por categoria de produto
- **Local de Estoque**: Filtro por almoxarifado/local
- **Somente com Saldo**: Exibe apenas produtos com saldo positivo

### Informações Exibidas

- Código do produto
- Descrição completa
- Categoria
- Local de estoque
- Unidade de medida
- Saldo atual
- Saldo disponível
- Custo médio
- Preço de venda

### Resumo Estatístico

- Total de produtos encontrados
- Quantidade com saldo positivo
- Quantidade sem saldo
- Valor total do estoque

## 🔧 Configuração da API

### Endpoints Disponíveis

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/consulta-estoque` | Consulta estoque com filtros |
| GET | `/locais-estoque` | Lista locais de estoque |
| GET | `/categorias-estoque` | Lista categorias |
| GET | `/produto-estoque/:codigo` | Busca produto específico |

### Parâmetros da Consulta

- `codigoProduto`: string (opcional)
- `descricaoProduto`: string (opcional)
- `categoria`: string (opcional)
- `local`: string (opcional)
- `somenteComSaldo`: boolean (opcional)

## 🎨 Customização

### Estilos

Os estilos podem ser customizados em:
- `src/styles.css` - Estilos globais
- `src/app/consulta-estoque/consulta-estoque.component.css` - Estilos específicos do componente

### Componentes PO-UI

O projeto utiliza os seguintes componentes PO-UI:
- `po-page-default`
- `po-table`
- `po-input`
- `po-select`
- `po-checkbox`
- `po-widget`
- `po-info`

## 🐛 Solução de Problemas

### Erro de CORS
Configure o CORS no servidor Protheus ou use um proxy durante o desenvolvimento.

### Erro de Conexão com API
Verifique se:
1. O serviço REST está ativo no Protheus
2. A URL da API está correta no environment
3. O firewall não está bloqueando a conexão

### Problemas de Performance
Para grandes volumes de dados:
1. Implemente paginação na API
2. Use filtros obrigatórios
3. Otimize as queries do banco

## 📝 Próximos Passos

- [ ] Implementar paginação
- [ ] Adicionar exportação para Excel
- [ ] Criar gráficos de análise
- [ ] Implementar cache no frontend
- [ ] Adicionar testes unitários
- [ ] Implementar autenticação/autorização

## 👨‍💻 Desenvolvedor

**Guilherme Souza**
- Desenvolvido em 2025
- Tecnologias: PO-UI, Angular, TLPP, Protheus

---

Para dúvidas ou sugestões, consulte a documentação oficial do [PO-UI](https://po-ui.io/) e [Protheus](https://tdn.totvs.com/).
