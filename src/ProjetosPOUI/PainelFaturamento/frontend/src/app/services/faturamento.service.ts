import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
import { environment } from '../../environments/environment';

// Interfaces para tipagem dos dados
export interface DashboardData {
  faturamentoTotal: number;
  faturamentoMes: number;
  pedidosPendentes: number;
  clientesAtivos: number;
  crescimento: number;
  metaMensal: number;
  graficos: {
    faturamentoDiario: Array<{data: string, valor: number}>;
    topProdutos: Array<{produto: string, quantidade: number, valor: number}>;
    vendedores: Array<{vendedor: string, valor: number}>;
  };
}

export interface PedidoPendente {
  numero: string;
  cliente: string;
  valor: number;
  dataEmissao: string;
  dataEntrega: string;
  vendedor: string;
  status: string;
  observacoes: string;
}

export interface RankingCliente {
  posicao: number;
  codigo: string;
  nome: string;
  cidade: string;
  faturamento: number;
  crescimento: number;
  ultimaCompra: string;
  categoria: string;
}

@Injectable({
  providedIn: 'root'
})
export class FaturamentoService {
  private apiUrl = environment.apiUrl;
  private readonly httpOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + this.getToken()
    })
  };

  constructor(private http: HttpClient) {}

  /**
   * Obtém dados do dashboard principal
   */
  getDashboardData(): Observable<DashboardData> {
    return this.http.get<any>(`${this.apiUrl}/faturamento/dashboard`, this.httpOptions)
      .pipe(
        map(response => {
          // Processa resposta do backend TLPP
          if (response && response.success) {
            return response.data;
          }
          throw new Error('Erro ao carregar dashboard');
        }),
        catchError(this.handleError<DashboardData>('getDashboardData'))
      );
  }

  /**
   * Obtém lista de pedidos pendentes
   */
  getPedidosPendentes(filtros?: any): Observable<PedidoPendente[]> {
    let params = new HttpParams();
    
    if (filtros) {
      if (filtros.dataInicio) params = params.set('dataInicio', filtros.dataInicio);
      if (filtros.dataFim) params = params.set('dataFim', filtros.dataFim);
      if (filtros.vendedor) params = params.set('vendedor', filtros.vendedor);
      if (filtros.cliente) params = params.set('cliente', filtros.cliente);
    }

    return this.http.get<any>(`${this.apiUrl}/pedidos/pendentes`, {
      ...this.httpOptions,
      params
    }).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        }
        throw new Error('Erro ao carregar pedidos pendentes');
      }),
      catchError(this.handleError<PedidoPendente[]>('getPedidosPendentes', []))
    );
  }

  /**
   * Obtém ranking de clientes
   */
  getRankingClientes(periodo?: string): Observable<RankingCliente[]> {
    let params = new HttpParams();
    if (periodo) {
      params = params.set('periodo', periodo);
    }

    return this.http.get<any>(`${this.apiUrl}/ranking/clientes`, {
      ...this.httpOptions,
      params
    }).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        }
        throw new Error('Erro ao carregar ranking de clientes');
      }),
      catchError(this.handleError<RankingCliente[]>('getRankingClientes', []))
    );
  }

  /**
   * Obtém dados para gráficos específicos
   */
  getGraficoFaturamento(tipo: string, periodo: string): Observable<any> {
    const params = new HttpParams()
      .set('tipo', tipo)
      .set('periodo', periodo);

    return this.http.get<any>(`${this.apiUrl}/graficos/faturamento`, {
      ...this.httpOptions,
      params
    }).pipe(
      map(response => {
        if (response && response.success) {
          return response.data;
        }
        throw new Error('Erro ao carregar gráfico');
      }),
      catchError(this.handleError<any>('getGraficoFaturamento'))
    );
  }

  /**
   * Atualiza status de um pedido
   */
  atualizarStatusPedido(numeroPedido: string, novoStatus: string): Observable<boolean> {
    const body = {
      numeroPedido,
      status: novoStatus
    };

    return this.http.put<any>(`${this.apiUrl}/pedidos/status`, body, this.httpOptions)
      .pipe(
        map(response => {
          return response && response.success;
        }),
        catchError(this.handleError<boolean>('atualizarStatusPedido', false))
      );
  }

  /**
   * Exporta relatório em Excel
   */
  exportarRelatorio(tipo: string, filtros: any): Observable<Blob> {
    const params = new HttpParams()
      .set('tipo', tipo)
      .set('filtros', JSON.stringify(filtros));

    return this.http.get(`${this.apiUrl}/relatorios/exportar`, {
      ...this.httpOptions,
      params,
      responseType: 'blob'
    }).pipe(
      catchError(this.handleError<Blob>('exportarRelatorio'))
    );
  }

  /**
   * Obtém token de autenticação (implementar conforme necessário)
   */
  private getToken(): string {
    // Por enquanto retorna vazio, implementar autenticação depois
    return localStorage.getItem('auth_token') || '';
  }

  /**
   * Manipulador de erros genérico
   */
  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      console.error(`${operation} failed:`, error);
      
      // Log do erro para monitoramento
      this.logError(operation, error);
      
      // Retorna resultado vazio para manter a aplicação funcionando
      return of(result as T);
    };
  }

  /**
   * Log de erros (implementar conforme necessário)
   */
  private logError(operation: string, error: any): void {
    // Implementar sistema de logging
    console.error(`Erro na operação ${operation}:`, error);
  }
}
