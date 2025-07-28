import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface FiltrosRelatorio {
  dtIni: string;
  dtFim: string;
  filial?: string;
  tpRel?: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  total?: number;
}

export interface LiberacaoItem {
  numLib: string;
  op: string;
  produto: string;
  corIBR: string;
  compMO: string;
  lote: string;
  quant: number;
  dataIni: string;
  horaIni: string;
  resultado: string;
  usuario: string;
}

export interface CorrecaoItem {
  numLib: string;
  numAna: number;
  codPig: string;
  quantPig: number;
  dataIni: string;
  horaIni: string;
  tecnico: string;
  tonalidade: string;
}

export interface DashboardData {
  totalLiberacoes: number;
  totalCorrecoes: number;
  aprovadas: number;
  reprovadas: number;
  pendentes: number;
  percentualAprovacao: number;
}

@Injectable({
  providedIn: 'root'
})
export class RelatorioCorService {

  private readonly baseUrl = environment.urlBackEnd || 'http://localhost:8080';
  private readonly apiPath = '/ws/rest/RCORAPI';

  constructor(private http: HttpClient) {}

  /**
   * Endpoint 1: Todas as Liberações (ZZS)
   * Baseado no método todasLib() do RCORAPI.tlpp
   */
  getTodasLiberacoes(filtros: FiltrosRelatorio): Observable<ApiResponse<LiberacaoItem[]>> {
    const params = this.buildHttpParams(filtros);
    return this.http.get<ApiResponse<LiberacaoItem[]>>(`${this.baseUrl}${this.apiPath}/todasLib`, { params });
  }

  /**
   * Endpoint 2: Todas as Correções (ZZT)
   * Baseado no método todasCor() do RCORAPI.tlpp
   */
  getTodasCorrecoes(filtros: FiltrosRelatorio): Observable<ApiResponse<CorrecaoItem[]>> {
    const params = this.buildHttpParams(filtros);
    return this.http.get<ApiResponse<CorrecaoItem[]>>(`${this.baseUrl}${this.apiPath}/todasCor`, { params });
  }

  /**
   * Endpoint 3: Liberações sem TO
   * Baseado no método libSemTO() do RCORAPI.tlpp
   */
  getLiberacoesSemTO(filtros: FiltrosRelatorio): Observable<ApiResponse<LiberacaoItem[]>> {
    const params = this.buildHttpParams(filtros);
    return this.http.get<ApiResponse<LiberacaoItem[]>>(`${this.baseUrl}${this.apiPath}/libSemTO`, { params });
  }

  /**
   * Endpoint 4: Liberações com TO
   * Baseado no método libComTO() do RCORAPI.tlpp
   */
  getLiberacoesComTO(filtros: FiltrosRelatorio): Observable<ApiResponse<LiberacaoItem[]>> {
    const params = this.buildHttpParams(filtros);
    return this.http.get<ApiResponse<LiberacaoItem[]>>(`${this.baseUrl}${this.apiPath}/libComTO`, { params });
  }

  /**
   * Endpoint 5: Correções sem TO
   * Baseado no método corSemTO() do RCORAPI.tlpp
   */
  getCorrecoesSemTO(filtros: FiltrosRelatorio): Observable<ApiResponse<CorrecaoItem[]>> {
    const params = this.buildHttpParams(filtros);
    return this.http.get<ApiResponse<CorrecaoItem[]>>(`${this.baseUrl}${this.apiPath}/corSemTO`, { params });
  }

  /**
   * Endpoint 6: Correções com TO
   * Baseado no método corComTO() do RCORAPI.tlpp
   */
  getCorrecoesComTO(filtros: FiltrosRelatorio): Observable<ApiResponse<CorrecaoItem[]>> {
    const params = this.buildHttpParams(filtros);
    return this.http.get<ApiResponse<CorrecaoItem[]>>(`${this.baseUrl}${this.apiPath}/corComTO`, { params });
  }

  /**
   * Endpoint 7: Dashboard - Dados consolidados
   * Baseado no método dashboard() do RCORAPI.tlpp
   */
  getDashboard(filtros: FiltrosRelatorio): Observable<ApiResponse<DashboardData>> {
    const params = this.buildHttpParams(filtros);
    return this.http.get<ApiResponse<DashboardData>>(`${this.baseUrl}${this.apiPath}/dashboard`, { params });
  }

  /**
   * Endpoint 8: Teste de conectividade
   * Baseado no método teste() do RCORAPI.tlpp
   */
  testarConexao(): Observable<ApiResponse<any>> {
    return this.http.get<ApiResponse<any>>(`${this.baseUrl}${this.apiPath}/teste`);
  }

  /**
   * Método auxiliar para construir HttpParams a partir dos filtros
   */
  private buildHttpParams(filtros: FiltrosRelatorio): HttpParams {
    let params = new HttpParams();

    if (filtros.dtIni) {
      params = params.set('dtIni', filtros.dtIni);
    }

    if (filtros.dtFim) {
      params = params.set('dtFim', filtros.dtFim);
    }

    if (filtros.filial) {
      params = params.set('filial', filtros.filial);
    }

    if (filtros.tpRel) {
      params = params.set('tpRel', filtros.tpRel);
    }

    return params;
  }

  /**
   * Método para validar conectividade com a API
   */
  validarConectividade(): Observable<boolean> {
    return new Observable(observer => {
      this.testarConexao().subscribe({
        next: (response) => {
          observer.next(response.success);
          observer.complete();
        },
        error: () => {
          observer.next(false);
          observer.complete();
        }
      });
    });
  }

  /**
   * Método para formatar datas no padrão esperado pelo backend TLPP
   */
  formatarDataParaApi(data: string): string {
    // Converte de YYYY-MM-DD para YYYYMMDD (formato Protheus)
    return data.replace(/-/g, '');
  }

  /**
   * Método para formatar dados para exportação
   */
  formatarParaExcel(dados: any[], tipo: 'liberacao' | 'correcao'): any[] {
    if (tipo === 'liberacao') {
      return dados.map(item => ({
        'Núm. Liberação': item.numLib,
        'OP': item.op,
        'Produto': item.produto,
        'Cor IBR': item.corIBR,
        'Comp. MO': item.compMO,
        'Lote': item.lote,
        'Quantidade': item.quant,
        'Data Início': item.dataIni,
        'Hora Início': item.horaIni,
        'Resultado': item.resultado,
        'Usuário': item.usuario
      }));
    } else {
      return dados.map(item => ({
        'Núm. Liberação': item.numLib,
        'Núm. Análise': item.numAna,
        'Cód. Pigmento': item.codPig,
        'Qtd. Pigmento': item.quantPig,
        'Data Início': item.dataIni,
        'Hora Início': item.horaIni,
        'Técnico': item.tecnico,
        'Tonalidade': item.tonalidade
      }));
    }
  }
}
