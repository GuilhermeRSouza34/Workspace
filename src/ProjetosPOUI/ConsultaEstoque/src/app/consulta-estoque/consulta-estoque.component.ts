import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { 
  PoSelectOption, 
  PoTableColumn, 
  PoTableAction,
  PoNotificationService,
  PoPageAction,
  PoCheckboxGroupOption
} from '@po-ui/ng-components';
import { EstoqueService } from '../services/estoque.service';
import { ProdutoEstoque, FiltroConsulta, LocalEstoque, CategoriaEstoque } from '../models/estoque.model';

@Component({
  selector: 'app-consulta-estoque',
  templateUrl: './consulta-estoque.component.html',
  styleUrls: ['./consulta-estoque.component.css']
})
export class ConsultaEstoqueComponent implements OnInit {
  formFiltros!: FormGroup;
  produtos: ProdutoEstoque[] = [];
  locais: PoSelectOption[] = [];
  categorias: PoSelectOption[] = [];
  loading = false;

  // Configuração das colunas da tabela
  readonly columns: PoTableColumn[] = [
    { property: 'codigo', label: 'Código', width: '10%' },
    { property: 'descricao', label: 'Descrição', width: '25%' },
    { property: 'categoria', label: 'Categoria', width: '10%' },
    { property: 'local', label: 'Local', width: '8%' },
    { property: 'unidade', label: 'UN', width: '5%' },
    { 
      property: 'saldoAtual', 
      label: 'Saldo Atual', 
      width: '10%',
      type: 'number',
      format: '1.2-2'
    },
    { 
      property: 'saldoDisponivel', 
      label: 'Saldo Disponível', 
      width: '12%',
      type: 'number',
      format: '1.2-2'
    },
    { 
      property: 'custoMedio', 
      label: 'Custo Médio', 
      width: '10%',
      type: 'currency',
      format: 'BRL'
    },
    { 
      property: 'precoVenda', 
      label: 'Preço Venda', 
      width: '10%',
      type: 'currency',
      format: 'BRL'
    }
  ];

  // Ações da página
  readonly pageActions: PoPageAction[] = [
    { 
      label: 'Consultar', 
      action: this.consultar.bind(this),
      icon: 'po-icon-search'
    },
    { 
      label: 'Limpar', 
      action: this.limparFiltros.bind(this),
      icon: 'po-icon-clean'
    },
    { 
      label: 'Exportar', 
      action: this.exportar.bind(this),
      icon: 'po-icon-export'
    },
    { 
      label: 'Testar Conexão', 
      action: this.testarConexao.bind(this),
      icon: 'po-icon-refresh'
    }
  ];

  constructor(
    private fb: FormBuilder,
    private estoqueService: EstoqueService,
    private poNotification: PoNotificationService
  ) {
    this.criarFormulario();
  }

  ngOnInit(): void {
    this.carregarDadosIniciais();
    // Dados mock para demonstração
    this.carregarDadosMock();
  }

  private criarFormulario(): void {
    this.formFiltros = this.fb.group({
      codigoProduto: [''],
      descricaoProduto: [''],
      categoria: [''],
      local: [''],
      somenteComSaldo: [false]
    });
  }

  private carregarDadosIniciais(): void {
    this.loading = true;
    
    // Carregar locais
    this.estoqueService.obterLocais().subscribe({
      next: (locais: LocalEstoque[]) => {
        this.locais = locais.map(local => ({
          value: local.codigo,
          label: `${local.codigo} - ${local.descricao}`
        }));
      },
      error: (error) => {
        this.poNotification.error('Erro ao carregar locais de estoque');
        console.error('Erro ao carregar locais:', error);
      }
    });

    // Carregar categorias
    this.estoqueService.obterCategorias().subscribe({
      next: (categorias: CategoriaEstoque[]) => {
        this.categorias = categorias.map(categoria => ({
          value: categoria.codigo,
          label: `${categoria.codigo} - ${categoria.descricao}`
        }));
      },
      error: (error) => {
        this.poNotification.error('Erro ao carregar categorias');
        console.error('Erro ao carregar categorias:', error);
      },
      complete: () => {
        this.loading = false;
      }
    });
  }

  consultar(): void {
    this.loading = true;
    const filtros: FiltroConsulta = this.formFiltros.value;

    this.estoqueService.consultarEstoque(filtros).subscribe({
      next: (produtos: ProdutoEstoque[]) => {
        this.produtos = produtos;
        this.poNotification.success(`${produtos.length} produto(s) encontrado(s)`);
      },
      error: (error) => {
        this.poNotification.error('Erro ao consultar estoque');
        console.error('Erro na consulta:', error);
        this.produtos = [];
      },
      complete: () => {
        this.loading = false;
      }
    });
  }

  limparFiltros(): void {
    this.formFiltros.reset();
    this.produtos = [];
  }

  exportar(): void {
    if (this.produtos.length === 0) {
      this.poNotification.warning('Não há dados para exportar');
      return;
    }

    try {
      // Converter dados para CSV
      const headers = ['Código', 'Descrição', 'Categoria', 'Local', 'Unidade', 'Saldo Atual', 'Saldo Disponível', 'Custo Médio', 'Preço Venda'];
      const csvData = this.produtos.map(produto => [
        produto.codigo,
        produto.descricao,
        produto.categoria,
        produto.local,
        produto.unidade,
        produto.saldoAtual,
        produto.saldoDisponivel,
        produto.custoMedio.toFixed(2),
        produto.precoVenda.toFixed(2)
      ]);

      const csvContent = [headers, ...csvData]
        .map(row => row.map(field => `"${field}"`).join(','))
        .join('\n');

      // Criar e fazer download do arquivo
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const link = document.createElement('a');
      const url = URL.createObjectURL(blob);
      link.setAttribute('href', url);
      link.setAttribute('download', `consulta-estoque-${new Date().toISOString().split('T')[0]}.csv`);
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      this.poNotification.success('Arquivo exportado com sucesso!');
    } catch (error) {
      this.poNotification.error('Erro ao exportar arquivo');
      console.error('Erro na exportação:', error);
    }
  }

  // Métodos para eventos da tabela
  onRowSelect(event: any): void {
    console.log('Produto selecionado:', event);
  }

  // Método para testar conectividade
  testarConexao(): void {
    this.loading = true;
    this.poNotification.information('Testando conectividade com a API...');

    this.estoqueService.testarConectividade().subscribe({
      next: () => {
        this.poNotification.success('✅ Conexão com a API funcionando corretamente!');
      },
      error: (error: any) => {
        this.poNotification.error(`❌ Erro de conectividade: ${error.message}`);
        console.error('Erro no teste de conectividade:', error);
      },
      complete: () => {
        this.loading = false;
      }
    });
  }

  // Método para calcular valor total do estoque
  calcularValorTotal(): number {
    return this.produtos.reduce((total, produto) => {
      return total + (produto.saldoAtual * produto.custoMedio);
    }, 0);
  }

  // Métodos auxiliares para o template
  getTotalProdutos(): string {
    return this.produtos.length.toString();
  }

  getProdutosComSaldo(): string {
    return this.produtos.filter(p => p.saldoAtual > 0).length.toString();
  }

  getProdutosSemSaldo(): string {
    return this.produtos.filter(p => p.saldoAtual <= 0).length.toString();
  }

  getValorTotalFormatado(): string {
    const valor = this.calcularValorTotal();
    return new Intl.NumberFormat('pt-BR', { 
      style: 'currency', 
      currency: 'BRL' 
    }).format(valor);
  }

  // Dados mock para demonstração (remove quando backend estiver funcionando)
  private carregarDadosMock(): void {
    // Locais mock
    this.locais = [
      { value: '01', label: '01 - Estoque Principal' },
      { value: '02', label: '02 - Estoque Filial' },
      { value: '03', label: '03 - Estoque Terceiros' }
    ];

    // Categorias mock
    this.categorias = [
      { value: '001', label: '001 - Produtos Acabados' },
      { value: '002', label: '002 - Matéria Prima' },
      { value: '003', label: '003 - Produtos em Processo' }
    ];

    // Produtos mock (para demonstração)
    this.produtos = [
      {
        codigo: 'PROD001',
        descricao: 'Produto Teste 1',
        categoria: '001',
        unidade: 'UN',
        local: '01',
        saldoAtual: 100,
        saldoDisponivel: 90,
        saldoReservado: 10,
        custoMedio: 15.50,
        precoVenda: 25.00,
        ultimaMovimentacao: new Date('2025-01-15'),
        ativo: true
      },
      {
        codigo: 'PROD002',
        descricao: 'Produto Teste 2',
        categoria: '002',
        unidade: 'KG',
        local: '01',
        saldoAtual: 50,
        saldoDisponivel: 45,
        saldoReservado: 5,
        custoMedio: 8.75,
        precoVenda: 15.00,
        ultimaMovimentacao: new Date('2025-01-20'),
        ativo: true
      },
      {
        codigo: 'PROD003',
        descricao: 'Produto Teste 3',
        categoria: '001',
        unidade: 'UN',
        local: '02',
        saldoAtual: 0,
        saldoDisponivel: 0,
        saldoReservado: 0,
        custoMedio: 12.30,
        precoVenda: 20.00,
        ultimaMovimentacao: new Date('2025-01-10'),
        ativo: true
      }
    ];
  }
}
