import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { 
  PoPageAction, 
  PoTableAction, 
  PoTableColumn,
  PoNotificationService
} from '@po-ui/ng-components';

@Component({
  selector: 'app-vendas-diarias',
  templateUrl: './vendas-diarias.component.html',
  styleUrls: ['./vendas-diarias.component.css']
})
export class VendasDiariasComponent implements OnInit {

  // Formulário de filtros
  filterForm!: FormGroup;
  
  // Dados
  vendasDiarias: any[] = [];
  totalizadores: any = null;
  
  // Estados
  isLoading = false;
  hasError = false;
  errorMessage = '';
  
  // Opções para mês
  readonly mesesOptions = [
    { value: '01', label: 'Janeiro' },
    { value: '02', label: 'Fevereiro' },
    { value: '03', label: 'Março' },
    { value: '04', label: 'Abril' },
    { value: '05', label: 'Maio' },
    { value: '06', label: 'Junho' },
    { value: '07', label: 'Julho' },
    { value: '08', label: 'Agosto' },
    { value: '09', label: 'Setembro' },
    { value: '10', label: 'Outubro' },
    { value: '11', label: 'Novembro' },
    { value: '12', label: 'Dezembro' }
  ];

  // Configurações PO-UI
  readonly columns: PoTableColumn[] = [
    {
      property: 'dia',
      label: 'Dia',
      type: 'number',
      width: '80px'
    },
    {
      property: 'qtdeVendida',
      label: 'Qtd. Vendida',
      type: 'number',
      format: '1.2-2',
      width: '120px'
    },
    {
      property: 'vlrVendido',
      label: 'Vlr. Vendido',
      type: 'currency',
      format: 'BRL',
      width: '140px'
    }
  ];

  constructor(
    private fb: FormBuilder,
    private poNotification: PoNotificationService
  ) {
    this.createForm();
  }

  ngOnInit(): void {
    this.initializeForm();
    this.consultar();
  }

  private createForm(): void {
    const hoje = new Date();
    const mesAtual = (hoje.getMonth() + 1).toString().padStart(2, '0');
    const anoAtual = hoje.getFullYear().toString();

    this.filterForm = this.fb.group({
      mes: [mesAtual, [Validators.required]],
      ano: [anoAtual, [Validators.required, Validators.pattern(/^\d{4}$/)]]
    });
  }

  private initializeForm(): void {
    // Inicialização já feita no createForm
  }

  consultar(): void {
    if (this.filterForm.invalid) {
      this.poNotification.warning('Por favor, verifique os campos obrigatórios.');
      return;
    }

    const { mes, ano } = this.filterForm.value;
    
    this.isLoading = true;
    this.hasError = false;

    // Simulando dados para demonstração
    setTimeout(() => {
      this.vendasDiarias = [
        {
          dia: 1,
          qtdeVendida: 1250.50,
          vlrVendido: 35420.80
        },
        {
          dia: 2,
          qtdeVendida: 980.25,
          vlrVendido: 28750.40
        },
        {
          dia: 3,
          qtdeVendida: 1540.75,
          vlrVendido: 42300.20
        }
      ];
      
      this.totalizadores = {
        totalVendasQtd: 3771.50,
        totalVendasVlr: 106471.40,
        totalTransfQtd: 0,
        totalDevolQtd: 0,
        totalDevolVlr: 0
      };
      
      this.isLoading = false;
      this.poNotification.success(`${this.vendasDiarias.length} registros encontrados para ${mes}/${ano}`);
    }, 2000);
  }

  exportarExcel(): void {
    this.poNotification.information('Funcionalidade de exportação será implementada.');
  }

  atualizar(): void {
    this.consultar();
  }

  // Getters para template
  get periodoSelecionado(): string {
    const { mes, ano } = this.filterForm.value;
    const mesNome = this.mesesOptions.find(m => m.value === mes)?.label || mes;
    return `${mesNome}/${ano}`;
  }

  get temDados(): boolean {
    return this.vendasDiarias.length > 0;
  }

  formatarNumero(value: number, decimais: number = 2): string {
    return new Intl.NumberFormat('pt-BR', {
      minimumFractionDigits: decimais,
      maximumFractionDigits: decimais
    }).format(value);
  }

  formatarMoeda(value: number): string {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  }
}
