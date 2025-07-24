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
  formFiltros: FormGroup;
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

    // Implementar exportação para Excel/CSV
    this.poNotification.information('Funcionalidade de exportação será implementada');
  }

  // Métodos para eventos da tabela
  onRowSelect(event: any): void {
    console.log('Produto selecionado:', event);
  }

  // Método para calcular valor total do estoque
  calcularValorTotal(): number {
    return this.produtos.reduce((total, produto) => {
      return total + (produto.saldoAtual * produto.custoMedio);
    }, 0);
  }
}
