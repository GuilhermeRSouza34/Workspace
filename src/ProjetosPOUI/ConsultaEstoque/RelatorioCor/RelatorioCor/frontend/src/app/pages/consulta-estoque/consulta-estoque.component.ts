import { Component, OnInit } from '@angular/core';
import { PoPageAction, PoTableColumn, PoNotificationService, PoDialogService } from '@po-ui/ng-components';
import { EstoqueService } from '../../core/services/estoque.service';
import { DashboardData, Liberacao, Correcao, Filtros } from '../../core/models/interfaces';

@Component({
  selector: 'app-consulta-estoque',
  templateUrl: './consulta-estoque.component.html',
  styleUrls: ['./consulta-estoque.component.css']
})
export class ConsultaEstoqueComponent implements OnInit {

  // ========================================
  // PROPRIEDADES GERAIS
  // ========================================
  
  loading = false;
  abaAtiva = 'dashboard';
  
  // Filtros
  filtros: Filtros = {
    dataIni: this.formatarDataHoje(-30), // 30 dias atrás
    dataFim: this.formatarDataHoje(0)    // Hoje
  };

  // ========================================
  // DADOS DO DASHBOARD
  // ========================================
  
  dashboardData: DashboardData = {
    totalLib: 0,
    totalCor: 0,
    aprovados: 0,
    reprovados: 0,
    percAprov: 0,
    mediaCorrOP: 0,
    tempoMedLib: '00:00:00',
    tecAtivo: '',
    pigMais: ''
  };

  // ========================================
  // DADOS DAS LIBERAÇÕES
  // ========================================
  
  liberacoes: Liberacao[] = [];
  
  colunasLiberacoes: PoTableColumn[] = [
    { property: 'numLib', label: 'Nº Liberação', width: '120px' },
    { property: 'op', label: 'OP', width: '100px' },
    { property: 'produto', label: 'Produto', width: '120px' },
    { property: 'corIBR', label: 'Cor IBR', width: '100px' },
    { property: 'lote', label: 'Lote', width: '100px' },
    { property: 'quant', label: 'Quantidade', width: '100px', type: 'number' },
    { property: 'dataIni', label: 'Data', width: '100px', type: 'date' },
    { property: 'horaIni', label: 'Hora Início', width: '100px' },
    { property: 'resultado', label: 'Resultado', width: '100px' },
    { property: 'usuario', label: 'Usuário', width: '100px' },
    { property: 'tonalidade', label: 'Tonalidade', width: '100px' },
    { property: 'maquina', label: 'Máquina', width: '100px' }
  ];

  // ========================================
  // DADOS DAS CORREÇÕES
  // ========================================
  
  correcoes: Correcao[] = [];
  
  colunasCorrecoes: PoTableColumn[] = [
    { property: 'numLib', label: 'Nº Liberação', width: '120px' },
    { property: 'numAna', label: 'Nº Análise', width: '100px', type: 'number' },
    { property: 'codPig', label: 'Código Pigmento', width: '140px' },
    { property: 'quantPig', label: 'Qtd Pigmento', width: '120px', type: 'number' },
    { property: 'dataIni', label: 'Data', width: '100px', type: 'date' },
    { property: 'horaIni', label: 'Hora Início', width: '100px' },
    { property: 'horaFim', label: 'Hora Fim', width: '100px' },
    { property: 'tecnico', label: 'Técnico', width: '120px' },
    { property: 'tonalidade', label: 'Tonalidade', width: '100px' },
    { property: 'compMO', label: 'Comp MO', width: '100px' }
  ];

  // ========================================
  // AÇÕES DA PÁGINA
  // ========================================
  
  acoesPagina: PoPageAction[] = [
    {
      label: 'Atualizar',
      action: () => this.atualizarDados(),
      icon: 'po-icon-refresh'
    },
    {
      label: 'Exportar Excel',
      action: () => this.exportarExcel(),
      icon: 'po-icon-export'
    },
    {
      label: 'Filtros',
      action: () => this.abrirFiltros(),
      icon: 'po-icon-filter'
    }
  ];

  // ========================================
  // LIFECYCLE
  // ========================================

  constructor(
    private estoqueService: EstoqueService,
    private notification: PoNotificationService,
    private dialog: PoDialogService
  ) { }

  ngOnInit(): void {
    this.carregarDados();
  }

  // ========================================
  // MÉTODOS PRINCIPAIS
  // ========================================

  /**
   * Carrega todos os dados da aplicação
   */
  carregarDados(): void {
    this.loading = true;
    
    // Testa conectividade primeiro
    this.estoqueService.testarConectividade().subscribe({
      next: (response) => {
        if (response.success) {
          this.notification.success('Conectado com sucesso ao servidor!');
          this.carregarDashboard();
          this.carregarLiberacoes();
          this.carregarCorrecoes();
        } else {
          this.notification.error('Erro na conectividade com o servidor');
        }
      },
      error: (error) => {
        this.notification.error('Erro ao conectar com o servidor: ' + error.message);
        this.loading = false;
      }
    });
  }

  /**
   * Carrega dados do dashboard
   */
  carregarDashboard(): void {
    this.estoqueService.buscarDashboard(this.filtros).subscribe({
      next: (response) => {
        if (response.success) {
          this.dashboardData = response.data;
        }
      },
      error: (error) => {
        this.notification.error('Erro ao carregar dashboard: ' + error.message);
      }
    });
  }

  /**
   * Carrega liberações
   */
  carregarLiberacoes(): void {
    this.estoqueService.listarLiberacoes(this.filtros).subscribe({
      next: (response) => {
        if (response.success) {
          this.liberacoes = response.data.map(lib => ({
            ...lib,
            dataIni: this.estoqueService.formatarDataDaAPI(lib.dataIni)
          }));
        }
      },
      error: (error) => {
        this.notification.error('Erro ao carregar liberações: ' + error.message);
      }
    });
  }

  /**
   * Carrega correções
   */
  carregarCorrecoes(): void {
    this.estoqueService.listarCorrecoes(this.filtros).subscribe({
      next: (response) => {
        if (response.success) {
          this.correcoes = response.data.map(cor => ({
            ...cor,
            dataIni: this.estoqueService.formatarDataDaAPI(cor.dataIni)
          }));
        }
        this.loading = false;
      },
      error: (error) => {
        this.notification.error('Erro ao carregar correções: ' + error.message);
        this.loading = false;
      }
    });
  }

  // ========================================
  // MÉTODOS DE AÇÃO
  // ========================================

  /**
   * Atualiza todos os dados
   */
  atualizarDados(): void {
    this.carregarDados();
  }

  /**
   * Exporta dados para Excel
   */
  exportarExcel(): void {
    this.notification.information('Funcionalidade de export em desenvolvimento');
  }

  /**
   * Abre modal de filtros
   */
  abrirFiltros(): void {
    this.dialog.alert({
      title: 'Filtros',
      message: 'Modal de filtros em desenvolvimento. Use os campos de data no topo da página.',
      ok: () => {}
    });
  }

  /**
   * Troca de aba
   */
  trocarAba(aba: string): void {
    this.abaAtiva = aba;
  }

  // ========================================
  // MÉTODOS AUXILIARES
  // ========================================

  /**
   * Formata data para hoje + offset de dias
   */
  private formatarDataHoje(offset: number): string {
    const hoje = new Date();
    hoje.setDate(hoje.getDate() + offset);
    
    const dia = hoje.getDate().toString().padStart(2, '0');
    const mes = (hoje.getMonth() + 1).toString().padStart(2, '0');
    const ano = hoje.getFullYear();
    
    return `${dia}/${mes}/${ano}`;
  }

  /**
   * Aplica filtros e recarrega dados
   */
  aplicarFiltros(): void {
    // Converte datas para formato API
    this.filtros.dataIni = this.estoqueService.formatarDataParaAPI(this.filtros.dataIni);
    this.filtros.dataFim = this.estoqueService.formatarDataParaAPI(this.filtros.dataFim);
    
    this.carregarDados();
  }
}
