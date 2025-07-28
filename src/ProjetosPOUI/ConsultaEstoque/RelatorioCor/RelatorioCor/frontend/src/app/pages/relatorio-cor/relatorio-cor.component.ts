import { Component, OnInit } from '@angular/core';
import { PoPageDynamicTableActions, PoPageDynamicTableField } from '@po-ui/ng-templates';
import { PoNotificationService, PoTableColumn, PoSelectOption } from '@po-ui/ng-components';
import { RelatorioCorService } from '../../core/services/relatorio-cor.service';

@Component({
  selector: 'app-relatorio-cor',
  templateUrl: './relatorio-cor.component.html',
  styleUrls: ['./relatorio-cor.component.css']
})
export class RelatorioCorComponent implements OnInit {

  // Dados das 6 abas baseadas no IBCOR02.PRW
  todasLiberacoes: any[] = [];
  todasCorrecoes: any[] = [];
  liberacoesSemTO: any[] = [];
  liberacoesComTO: any[] = [];
  correcoesSemTO: any[] = [];
  correcoesComTO: any[] = [];
  dashboardData: any = {};

  // Controles da interface
  loading = false;
  abaAtiva = 1;
  filtros = {
    dtIni: '',
    dtFim: '',
    filial: '01',
    tpRel: 'RESUMO'
  };

  // Opções dos filtros
  tipoRelatorioOptions: PoSelectOption[] = [
    { label: 'Resumo', value: 'RESUMO' },
    { label: 'Detalhado', value: 'DETALHADO' },
    { label: 'Analítico', value: 'ANALITICO' }
  ];

  filialOptions: PoSelectOption[] = [
    { label: 'Filial 01', value: '01' },
    { label: 'Filial 02', value: '02' },
    { label: 'Todas', value: '' }
  ];

  // Colunas das tabelas
  colunasLiberacoes: PoTableColumn[] = [
    { property: 'numLib', label: 'Núm. Liberação', width: '12%' },
    { property: 'op', label: 'OP', width: '10%' },
    { property: 'produto', label: 'Produto', width: '12%' },
    { property: 'corIBR', label: 'Cor IBR', width: '10%' },
    { property: 'compMO', label: 'Comp. MO', width: '8%' },
    { property: 'lote', label: 'Lote', width: '10%' },
    { property: 'quant', label: 'Quantidade', type: 'number', width: '8%' },
    { property: 'dataIni', label: 'Data Início', type: 'date', width: '10%' },
    { property: 'horaIni', label: 'Hora Início', width: '8%' },
    { property: 'resultado', label: 'Resultado', width: '8%' },
    { property: 'usuario', label: 'Usuário', width: '8%' }
  ];

  colunasCorrecoes: PoTableColumn[] = [
    { property: 'numLib', label: 'Núm. Liberação', width: '15%' },
    { property: 'numAna', label: 'Núm. Análise', type: 'number', width: '12%' },
    { property: 'codPig', label: 'Cód. Pigmento', width: '15%' },
    { property: 'quantPig', label: 'Qtd. Pigmento', type: 'number', width: '12%' },
    { property: 'dataIni', label: 'Data Início', type: 'date', width: '12%' },
    { property: 'horaIni', label: 'Hora Início', width: '10%' },
    { property: 'tecnico', label: 'Técnico', width: '12%' },
    { property: 'tonalidade', label: 'Tonalidade', width: '12%' }
  ];

  constructor(
    private relatorioService: RelatorioCorService,
    private notification: PoNotificationService
  ) {}

  ngOnInit(): void {
    this.inicializarFiltros();
    this.carregarDashboard();
  }

  inicializarFiltros(): void {
    const hoje = new Date();
    const primeiroDia = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
    
    this.filtros.dtIni = this.formatarData(primeiroDia);
    this.filtros.dtFim = this.formatarData(hoje);
  }

  formatarData(data: Date): string {
    return data.toISOString().split('T')[0];
  }

  // Métodos para carregar dados das 6 abas
  carregarTodasLiberacoes(): void {
    this.loading = true;
    this.relatorioService.getTodasLiberacoes(this.filtros).subscribe({
      next: (response) => {
        this.todasLiberacoes = response.data || [];
        this.loading = false;
        this.notification.success(`Carregadas ${this.todasLiberacoes.length} liberações`);
      },
      error: (error) => {
        this.loading = false;
        this.notification.error('Erro ao carregar liberações');
        console.error(error);
      }
    });
  }

  carregarTodasCorrecoes(): void {
    this.loading = true;
    this.relatorioService.getTodasCorrecoes(this.filtros).subscribe({
      next: (response) => {
        this.todasCorrecoes = response.data || [];
        this.loading = false;
        this.notification.success(`Carregadas ${this.todasCorrecoes.length} correções`);
      },
      error: (error) => {
        this.loading = false;
        this.notification.error('Erro ao carregar correções');
        console.error(error);
      }
    });
  }

  carregarLiberacoesSemTO(): void {
    this.loading = true;
    this.relatorioService.getLiberacoesSemTO(this.filtros).subscribe({
      next: (response) => {
        this.liberacoesSemTO = response.data || [];
        this.loading = false;
      },
      error: (error) => {
        this.loading = false;
        this.notification.error('Erro ao carregar liberações sem TO');
        console.error(error);
      }
    });
  }

  carregarLiberacoesComTO(): void {
    this.loading = true;
    this.relatorioService.getLiberacoesComTO(this.filtros).subscribe({
      next: (response) => {
        this.liberacoesComTO = response.data || [];
        this.loading = false;
      },
      error: (error) => {
        this.loading = false;
        this.notification.error('Erro ao carregar liberações com TO');
        console.error(error);
      }
    });
  }

  carregarCorrecoesSemTO(): void {
    this.loading = true;
    this.relatorioService.getCorrecoesSemTO(this.filtros).subscribe({
      next: (response) => {
        this.correcoesSemTO = response.data || [];
        this.loading = false;
      },
      error: (error) => {
        this.loading = false;
        this.notification.error('Erro ao carregar correções sem TO');
        console.error(error);
      }
    });
  }

  carregarCorrecoesComTO(): void {
    this.loading = true;
    this.relatorioService.getCorrecoesComTO(this.filtros).subscribe({
      next: (response) => {
        this.correcoesComTO = response.data || [];
        this.loading = false;
      },
      error: (error) => {
        this.loading = false;
        this.notification.error('Erro ao carregar correções com TO');
        console.error(error);
      }
    });
  }

  carregarDashboard(): void {
    this.relatorioService.getDashboard(this.filtros).subscribe({
      next: (response) => {
        this.dashboardData = response.data || {};
      },
      error: (error) => {
        console.error('Erro ao carregar dashboard:', error);
      }
    });
  }

  // Eventos da interface
  onAbaChange(aba: number): void {
    this.abaAtiva = aba;
    this.carregarDadosAba();
  }

  carregarDadosAba(): void {
    switch (this.abaAtiva) {
      case 1:
        this.carregarTodasLiberacoes();
        break;
      case 2:
        this.carregarTodasCorrecoes();
        break;
      case 3:
        this.carregarLiberacoesSemTO();
        break;
      case 4:
        this.carregarLiberacoesComTO();
        break;
      case 5:
        this.carregarCorrecoesSemTO();
        break;
      case 6:
        this.carregarCorrecoesComTO();
        break;
    }
  }

  onFiltroChange(): void {
    this.carregarDadosAba();
    this.carregarDashboard();
  }

  limparFiltros(): void {
    this.inicializarFiltros();
    this.filtros.filial = '01';
    this.filtros.tpRel = 'RESUMO';
    this.onFiltroChange();
  }

  exportarExcel(): void {
    this.notification.success('Funcionalidade de exportação será implementada');
  }
}
