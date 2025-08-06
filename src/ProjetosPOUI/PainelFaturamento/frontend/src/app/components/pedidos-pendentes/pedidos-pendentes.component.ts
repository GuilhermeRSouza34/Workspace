import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { FaturamentoService, PedidoPendente } from '../../services/faturamento.service';
import { PoTableColumn, PoTableAction, PoPageAction, PoSelectOption, PoNotificationService } from '@po-ui/ng-components';

@Component({
  selector: 'app-pedidos-pendentes',
  templateUrl: './pedidos-pendentes.component.html',
  styleUrls: ['./pedidos-pendentes.component.scss']
})
export class PedidosPendentesComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  
  // Dados
  pedidos: PedidoPendente[] = [];
  pedidosFiltrados: PedidoPendente[] = [];
  isLoading = true;
  
  // Filtros
  filtros = {
    dataInicio: '',
    dataFim: '',
    vendedor: '',
    cliente: '',
    status: ''
  };

  // Opções de filtros
  vendedoresOptions: PoSelectOption[] = [];
  statusOptions: PoSelectOption[] = [
    { label: 'Todos', value: '' },
    { label: 'Em Análise', value: 'ANALISE' },
    { label: 'Aprovado', value: 'APROVADO' },
    { label: 'Pendente Estoque', value: 'PENDENTE_ESTOQUE' },
    { label: 'Em Separação', value: 'SEPARACAO' },
    { label: 'Aguardando Faturamento', value: 'AGUARD_FAT' }
  ];

  // Configuração da tabela
  columns: PoTableColumn[] = [
    { 
      property: 'numero', 
      label: 'Pedido',
      type: 'link',
      action: this.visualizarPedido.bind(this)
    },
    { property: 'cliente', label: 'Cliente' },
    { 
      property: 'valor', 
      label: 'Valor',
      type: 'currency',
      format: 'BRL'
    },
    { 
      property: 'dataEmissao', 
      label: 'Dt. Emissão',
      type: 'date'
    },
    { 
      property: 'dataEntrega', 
      label: 'Dt. Entrega',
      type: 'date'
    },
    { property: 'vendedor', label: 'Vendedor' },
    { 
      property: 'status', 
      label: 'Status',
      type: 'label',
      labels: [
        { value: 'ANALISE', color: 'color-08', label: 'Em Análise' },
        { value: 'APROVADO', color: 'color-11', label: 'Aprovado' },
        { value: 'PENDENTE_ESTOQUE', color: 'color-07', label: 'Pendente Estoque' },
        { value: 'SEPARACAO', color: 'color-05', label: 'Em Separação' },
        { value: 'AGUARD_FAT', color: 'color-02', label: 'Aguard. Faturamento' }
      ]
    }
  ];

  // Ações da tabela
  actions: PoTableAction[] = [
    {
      action: this.atualizarStatus.bind(this),
      label: 'Atualizar Status',
      icon: 'ph ph-pencil'
    },
    {
      action: this.visualizarDetalhes.bind(this),
      label: 'Ver Detalhes',
      icon: 'ph ph-eye'
    }
  ];

  // Ações da página
  pageActions: PoPageAction[] = [
    {
      label: 'Exportar Excel',
      action: this.exportarExcel.bind(this),
      icon: 'ph ph-file-xls'
    },
    {
      label: 'Atualizar',
      action: this.carregarPedidos.bind(this),
      icon: 'ph ph-arrow-clockwise'
    }
  ];

  constructor(
    private faturamentoService: FaturamentoService,
    private notification: PoNotificationService
  ) {}

  ngOnInit(): void {
    this.carregarPedidos();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  /**
   * Carrega os pedidos pendentes
   */
  carregarPedidos(): void {
    this.isLoading = true;
    
    this.faturamentoService.getPedidosPendentes(this.filtros)
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (pedidos) => {
          this.pedidos = pedidos;
          this.pedidosFiltrados = [...pedidos];
          this.extrairVendedores();
          this.isLoading = false;
        },
        error: (error) => {
          console.error('Erro ao carregar pedidos:', error);
          this.notification.error('Erro ao carregar pedidos pendentes');
          this.isLoading = false;
        }
      });
  }

  /**
   * Extrai lista única de vendedores para o filtro
   */
  private extrairVendedores(): void {
    const vendedoresUnicos = [...new Set(this.pedidos.map(p => p.vendedor))];
    this.vendedoresOptions = [
      { label: 'Todos', value: '' },
      ...vendedoresUnicos.map(v => ({ label: v, value: v }))
    ];
  }

  /**
   * Aplica filtros aos pedidos
   */
  aplicarFiltros(): void {
    this.pedidosFiltrados = this.pedidos.filter(pedido => {
      let incluir = true;

      if (this.filtros.vendedor && pedido.vendedor !== this.filtros.vendedor) {
        incluir = false;
      }

      if (this.filtros.status && pedido.status !== this.filtros.status) {
        incluir = false;
      }

      if (this.filtros.cliente && 
          !pedido.cliente.toLowerCase().includes(this.filtros.cliente.toLowerCase())) {
        incluir = false;
      }

      if (this.filtros.dataInicio) {
        const dataEmissao = new Date(pedido.dataEmissao);
        const dataInicio = new Date(this.filtros.dataInicio);
        if (dataEmissao < dataInicio) {
          incluir = false;
        }
      }

      if (this.filtros.dataFim) {
        const dataEmissao = new Date(pedido.dataEmissao);
        const dataFim = new Date(this.filtros.dataFim);
        if (dataEmissao > dataFim) {
          incluir = false;
        }
      }

      return incluir;
    });
  }

  /**
   * Limpa todos os filtros
   */
  limparFiltros(): void {
    this.filtros = {
      dataInicio: '',
      dataFim: '',
      vendedor: '',
      cliente: '',
      status: ''
    };
    this.pedidosFiltrados = [...this.pedidos];
  }

  /**
   * Visualiza detalhes do pedido
   */
  visualizarPedido(pedido: PedidoPendente): void {
    // Implementar modal ou navegação para detalhes
    console.log('Visualizar pedido:', pedido.numero);
  }

  /**
   * Atualiza status do pedido
   */
  atualizarStatus(pedido: PedidoPendente): void {
    // Implementar modal para alterar status
    console.log('Atualizar status:', pedido.numero);
  }

  /**
   * Visualiza detalhes completos do pedido
   */
  visualizarDetalhes(pedido: PedidoPendente): void {
    // Implementar modal com detalhes completos
    console.log('Ver detalhes:', pedido.numero);
  }

  /**
   * Exporta dados para Excel
   */
  exportarExcel(): void {
    this.faturamentoService.exportarRelatorio('pedidos-pendentes', this.filtros)
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (blob) => {
          const url = window.URL.createObjectURL(blob);
          const link = document.createElement('a');
          link.href = url;
          link.download = `pedidos-pendentes-${new Date().toISOString().split('T')[0]}.xlsx`;
          link.click();
          window.URL.revokeObjectURL(url);
          this.notification.success('Relatório exportado com sucesso!');
        },
        error: (error) => {
          console.error('Erro ao exportar:', error);
          this.notification.error('Erro ao exportar relatório');
        }
      });
  }

  /**
   * Retorna resumo dos pedidos
   */
  getResumo(): any {
    const total = this.pedidosFiltrados.length;
    const valorTotal = this.pedidosFiltrados.reduce((sum, p) => sum + p.valor, 0);
    
    return {
      total,
      valorTotal,
      emAnalise: this.pedidosFiltrados.filter(p => p.status === 'ANALISE').length,
      aprovados: this.pedidosFiltrados.filter(p => p.status === 'APROVADO').length,
      pendentes: this.pedidosFiltrados.filter(p => p.status === 'PENDENTE_ESTOQUE').length
    };
  }
}
