import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse, Liberacao, Correcao, DashboardData, Filtros } from '../models/interfaces';

@Injectable({
  providedIn: 'root'
})
export class EstoqueService {
  
  private baseUrl = environment.urlBackEnd;

  constructor(private http: HttpClient) { }

  // ========================================
  // MÉTODOS PARA LIBERAÇÕES (ZZS)
  // ========================================

  /**
   * Lista todas as liberações com filtros
   */
  listarLiberacoes(filtros?: Filtros): Observable<ApiResponse<Liberacao[]>> {
    let params = new HttpParams();
    
    if (filtros) {
      if (filtros.dataIni) params = params.set('dataIni', filtros.dataIni);
      if (filtros.dataFim) params = params.set('dataFim', filtros.dataFim);
      if (filtros.filial) params = params.set('filial', filtros.filial);
      if (filtros.tpRel) params = params.set('tpRel', filtros.tpRel);
    }

    return this.http.get<ApiResponse<Liberacao[]>>(`${this.baseUrl}/liberacoes`, { params });
  }

  /**
   * Busca uma liberação específica por ID
   */
  buscarLiberacao(id: number): Observable<ApiResponse<Liberacao>> {
    return this.http.get<ApiResponse<Liberacao>>(`${this.baseUrl}/liberacoes/${id}`);
  }

  /**
   * Cria uma nova liberação
   */
  criarLiberacao(liberacao: Partial<Liberacao>): Observable<ApiResponse<Liberacao>> {
    return this.http.post<ApiResponse<Liberacao>>(`${this.baseUrl}/liberacoes`, liberacao);
  }

  /**
   * Atualiza uma liberação existente
   */
  atualizarLiberacao(id: number, liberacao: Partial<Liberacao>): Observable<ApiResponse<Liberacao>> {
    return this.http.put<ApiResponse<Liberacao>>(`${this.baseUrl}/liberacoes/${id}`, liberacao);
  }

  /**
   * Exclui uma liberação
   */
  excluirLiberacao(id: number): Observable<ApiResponse<boolean>> {
    return this.http.delete<ApiResponse<boolean>>(`${this.baseUrl}/liberacoes/${id}`);
  }

  // ========================================
  // MÉTODOS PARA CORREÇÕES (ZZT)
  // ========================================

  /**
   * Lista todas as correções com filtros
   */
  listarCorrecoes(filtros?: Filtros): Observable<ApiResponse<Correcao[]>> {
    let params = new HttpParams();
    
    if (filtros) {
      if (filtros.dataIni) params = params.set('dataIni', filtros.dataIni);
      if (filtros.dataFim) params = params.set('dataFim', filtros.dataFim);
      if (filtros.filial) params = params.set('filial', filtros.filial);
    }

    return this.http.get<ApiResponse<Correcao[]>>(`${this.baseUrl}/correcoes`, { params });
  }

  /**
   * Busca uma correção específica por ID
   */
  buscarCorrecao(id: number): Observable<ApiResponse<Correcao>> {
    return this.http.get<ApiResponse<Correcao>>(`${this.baseUrl}/correcoes/${id}`);
  }

  // ========================================
  // MÉTODOS PARA DASHBOARD
  // ========================================

  /**
   * Busca dados do dashboard (KPIs)
   */
  buscarDashboard(filtros?: Filtros): Observable<ApiResponse<DashboardData>> {
    let params = new HttpParams();
    
    if (filtros) {
      if (filtros.dataIni) params = params.set('dataIni', filtros.dataIni);
      if (filtros.dataFim) params = params.set('dataFim', filtros.dataFim);
    }

    return this.http.get<ApiResponse<DashboardData>>(`${this.baseUrl}/dashboard`, { params });
  }

  // ========================================
  // MÉTODOS AUXILIARES
  // ========================================

  /**
   * Testa conectividade com a API
   */
  testarConectividade(): Observable<ApiResponse<any>> {
    return this.http.get<ApiResponse<any>>(`${this.baseUrl}/teste`);
  }

  /**
   * Formata data no padrão brasileiro para YYYYMMDD
   */
  formatarDataParaAPI(data: string): string {
    if (!data) return '';
    
    // Se já está no formato YYYYMMDD, retorna
    if (data.length === 8 && !data.includes('/')) {
      return data;
    }
    
    // Se está no formato DD/MM/YYYY, converte
    if (data.includes('/')) {
      const [dia, mes, ano] = data.split('/');
      return `${ano}${mes.padStart(2, '0')}${dia.padStart(2, '0')}`;
    }
    
    return data;
  }

  /**
   * Formata data da API (YYYYMMDD) para padrão brasileiro (DD/MM/YYYY)
   */
  formatarDataDaAPI(data: string): string {
    if (!data || data.length !== 8) return data;
    
    const ano = data.substring(0, 4);
    const mes = data.substring(4, 6);
    const dia = data.substring(6, 8);
    
    return `${dia}/${mes}/${ano}`;
  }

  /**
   * Formata número para exibição
   */
  formatarNumero(valor: number, decimais: number = 2): string {
    return valor.toLocaleString('pt-BR', {
      minimumFractionDigits: decimais,
      maximumFractionDigits: decimais
    });
  }
}
