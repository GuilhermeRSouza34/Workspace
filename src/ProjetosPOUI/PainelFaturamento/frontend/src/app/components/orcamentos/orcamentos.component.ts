import { Component, OnInit } from '@angular/core';
import { PoTableColumn, PoSelectOption, PoNotificationService } from '@po-ui/ng-components';
// import { FaturamentoService } from '../../services/faturamento.service';

@Component({
  selector: 'app-orcamentos',
  templateUrl: './orcamentos.component.html',
  styleUrls: ['./orcamentos.component.scss']
})
export class OrcamentosComponent implements OnInit {
  // Dados
  orcamentos: any[] = [];
  orcamentosPaginados: any[] = [];
  carregando = false;
  mensagem = '';
  ultimaAtualizacao: Date = new Date();
  
  // Paginação
  paginaAtual = 1;
  tamanhoPagina = 20;
  totalRegistros = 0;
  totalPaginas = 0;
  
  // Filtros
  filtros = {
    dataInicio: null as Date | null,
    dataFim: null as Date | null,
    status: '',
    empresa: ''
  };
  
  // Resumo
  resumo = {
    quantidadeTotal: 0,
    valorTotal: 0,
    valorMedio: 0
  };
  
  // Opções para selects
  statusOptions: PoSelectOption[] = [
    { label: 'Todos', value: '' },
    { label: 'Aberto', value: '1' },
    { label: 'Liberado', value: '2' },
    { label: 'Perdido', value: '3' },
    { label: 'Bloqueado', value: '9' }
  ];
  
  empresaOptions: PoSelectOption[] = [
    { label: 'Todas', value: '' },
    { label: 'IBRATIN-SP', value: '01' },
    { label: 'AFA', value: '02' },
    { label: 'IBRATIN-SUL', value: '03' }
  ];
  
  // Colunas da tabela
  colunas: PoTableColumn[] = [
    { 
      property: 'empresa', 
      label: 'Empresa',
      width: '120px'
    },
    { 
      property: 'numero', 
      label: 'Número',
      width: '100px',
      type: 'link',
      action: this.verDetalhes.bind(this)
    },
    { 
      property: 'statusDesc', 
      label: 'Status',
      width: '100px'
    },
    { 
      property: 'valor', 
      label: 'Valor',
      type: 'currency',
      format: 'BRL',
      width: '120px'
    },
    { 
      property: 'nomeCliente', 
      label: 'Cliente',
      width: '200px'
    },
    { 
      property: 'dataEmissao', 
      label: 'Data Emissão',
      type: 'date',
      format: 'dd/MM/yyyy',
      width: '120px'
    },
    { 
      property: 'dataValidade', 
      label: 'Validade',
      type: 'date',
      format: 'dd/MM/yyyy',
      width: '120px'
    },
    { 
      property: 'vendedor', 
      label: 'Vendedor',
      width: '150px'
    }
  ];

  constructor(
    // private faturamentoService: FaturamentoService,
    private notification: PoNotificationService
  ) { }

  ngOnInit(): void {
    this.inicializarFiltros();
    this.carregarDadosDemo();
  }

  inicializarFiltros(): void {
    // Definir data inicial como 30 dias atrás
    const hoje = new Date();
    const trintaDiasAtras = new Date();
    trintaDiasAtras.setDate(hoje.getDate() - 30);
    
    this.filtros.dataInicio = trintaDiasAtras;
    this.filtros.dataFim = hoje;
  }

  carregarDadosDemo(): void {
    this.carregando = true;
    
    // Simular dados para teste
    setTimeout(() => {
      this.orcamentos = [
        {
          empresa: 'IBRATIN-SP',
          numero: '00001',
          statusDesc: 'Aberto',
          valor: 15000.50,
          nomeCliente: 'Cliente Teste 1',
          dataEmissao: '2025-07-15',
          dataValidade: '2025-08-15',
          vendedor: 'João Silva'
        },
        {
          empresa: 'AFA',
          numero: '00002',
          statusDesc: 'Liberado',
          valor: 25000.00,
          nomeCliente: 'Cliente Teste 2',
          dataEmissao: '2025-07-20',
          dataValidade: '2025-08-20',
          vendedor: 'Maria Santos'
        }
      ];
      
      this.totalRegistros = this.orcamentos.length;
      this.calcularPaginacao();
      this.atualizarOrcamentosPaginados();
      this.calcularResumo();
      this.ultimaAtualizacao = new Date();
      this.carregando = false;
      
      this.notification.success('Dados de demonstração carregados!');
    }, 1000);
  }

  buscarOrcamentos(): void {
    this.carregarDadosDemo();
  }

  limparFiltros(): void {
    this.filtros = {
      dataInicio: null,
      dataFim: null,
      status: '',
      empresa: ''
    };
    this.paginaAtual = 1;
    this.inicializarFiltros();
  }

  exportarExcel(): void {
    this.notification.success('Funcionalidade de exportação em desenvolvimento');
  }

  mudarPagina(novaPagina: number): void {
    if (novaPagina !== this.paginaAtual) {
      this.paginaAtual = novaPagina;
      this.buscarOrcamentos();
    }
  }

  verDetalhes(item: any): void {
    this.notification.information(`Detalhes do orçamento ${item.numero} - ${item.empresa}`);
  }

  private calcularPaginacao(): void {
    this.totalPaginas = Math.ceil(this.totalRegistros / this.tamanhoPagina);
  }

  private atualizarOrcamentosPaginados(): void {
    this.orcamentosPaginados = this.orcamentos;
  }

  private calcularResumo(): void {
    if (this.orcamentos.length > 0) {
      this.resumo.quantidadeTotal = this.totalRegistros;
      this.resumo.valorTotal = this.orcamentos.reduce((total, item) => total + (item.valor || 0), 0);
      this.resumo.valorMedio = this.resumo.valorTotal / this.orcamentos.length;
    } else {
      this.resumo = {
        quantidadeTotal: 0,
        valorTotal: 0,
        valorMedio: 0
      };
    }
  }

  private formatDate(date: Date): string {
    return date.toISOString().split('T')[0]; // YYYY-MM-DD
  }
}
