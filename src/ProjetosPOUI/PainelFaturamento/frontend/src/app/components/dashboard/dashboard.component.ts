import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { FaturamentoService, DashboardData } from '../../services/faturamento.service';
import { PoChartType, PoChartOptions } from '@po-ui/ng-components';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  
  // Dados do dashboard
  dashboardData: DashboardData | null = null;
  isLoading = true;
  
  // Configurações dos gráficos
  chartFaturamento: any = {};
  chartProdutos: any = {};
  chartVendedores: any = {};
  
  // Opções dos gráficos PO-UI
  chartOptions: PoChartOptions = {
    axis: {
      minRange: 0,
      gridLines: 5
    }
  };

  // Cards de KPIs
  cards = [
    {
      title: 'Faturamento Total',
      value: 0,
      variation: 0,
      icon: 'ph ph-currency-dollar',
      color: 'color-11'
    },
    {
      title: 'Pedidos Pendentes',
      value: 0,
      variation: 0,
      icon: 'ph ph-clock',
      color: 'color-08'
    },
    {
      title: 'Clientes Ativos',
      value: 0,
      variation: 0,
      icon: 'ph ph-users',
      color: 'color-05'
    },
    {
      title: 'Meta Mensal',
      value: 0,
      variation: 0,
      icon: 'ph ph-target',
      color: 'color-02'
    }
  ];

  constructor(private faturamentoService: FaturamentoService) {}

  ngOnInit(): void {
    this.carregarDashboard();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  /**
   * Carrega todos os dados do dashboard
   */
  carregarDashboard(): void {
    this.isLoading = true;
    
    this.faturamentoService.getDashboardData()
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (data) => {
          this.dashboardData = data;
          this.atualizarCards();
          this.configurarGraficos();
          this.isLoading = false;
        },
        error: (error) => {
          console.error('Erro ao carregar dashboard:', error);
          this.isLoading = false;
        }
      });
  }

  /**
   * Atualiza os cards de KPI com os dados recebidos
   */
  private atualizarCards(): void {
    if (!this.dashboardData) return;

    this.cards[0].value = this.dashboardData.faturamentoTotal;
    this.cards[0].variation = this.dashboardData.crescimento;
    
    this.cards[1].value = this.dashboardData.pedidosPendentes;
    this.cards[1].variation = 0; // Calcular variação se necessário
    
    this.cards[2].value = this.dashboardData.clientesAtivos;
    this.cards[2].variation = 0; // Calcular variação se necessário
    
    this.cards[3].value = this.dashboardData.metaMensal;
    this.cards[3].variation = this.calcularProgressoMeta();
  }

  /**
   * Configura os gráficos com os dados recebidos
   */
  private configurarGraficos(): void {
    if (!this.dashboardData) return;

    // Gráfico de faturamento diário (linha)
    this.chartFaturamento = {
      type: PoChartType.Line,
      title: 'Faturamento Diário',
      series: [{
        name: 'Faturamento',
        data: this.dashboardData.graficos.faturamentoDiario.map(item => ({
          category: item.data,
          value: item.valor
        }))
      }],
      options: this.chartOptions
    };

    // Gráfico de top produtos (coluna)
    this.chartProdutos = {
      type: PoChartType.Column,
      title: 'Top Produtos',
      series: [{
        name: 'Quantidade',
        data: this.dashboardData.graficos.topProdutos.map(item => ({
          category: item.produto,
          value: item.quantidade
        }))
      }],
      options: this.chartOptions
    };

    // Gráfico de vendedores (pizza)
    this.chartVendedores = {
      type: PoChartType.Pie,
      title: 'Faturamento por Vendedor',
      series: this.dashboardData.graficos.vendedores.map(item => ({
        category: item.vendedor,
        value: item.valor
      })),
      options: this.chartOptions
    };
  }

  /**
   * Calcula o progresso da meta mensal
   */
  private calcularProgressoMeta(): number {
    if (!this.dashboardData) return 0;
    
    const progresso = (this.dashboardData.faturamentoMes / this.dashboardData.metaMensal) * 100;
    return Math.round(progresso);
  }

  /**
   * Formata valores monetários
   */
  formatarMoeda(valor: number): string {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(valor);
  }

  /**
   * Formata números
   */
  formatarNumero(valor: number): string {
    return new Intl.NumberFormat('pt-BR').format(valor);
  }

  /**
   * Retorna a classe CSS para a variação (positiva/negativa)
   */
  getVariationClass(variation: number): string {
    return variation >= 0 ? 'positive' : 'negative';
  }

  /**
   * Atualiza os dados do dashboard
   */
  atualizarDados(): void {
    this.carregarDashboard();
  }
}
