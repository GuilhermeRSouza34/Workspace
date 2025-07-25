import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface VendaDiaria {
  dia: number;
  qtdeVendida: number;
  vlrVendido: number;
  qtdeRemessa: number;
  vlrRemessa: number;
  qtdeFaturaTudo: number;
  vlrFaturaTudo: number;
  qtdeDevolucao: number;
  vlrDevolucao: number;
  qtdeDevRemessa: number;
  vlrDevRemessa: number;
  qtdeDevFaturaTudo: number;
  vlrDevFaturaTudo: number;
  qtdeTransferencia: number;
  vlrTransferencia: number;
  totalEntregueQtd: number;
  totalEntregueVlr: number;
  totalVendidoQtd: number;
  totalVendidoVlr: number;
}

export interface VendasDiariasResponse {
  success: boolean;
  message: string;
  periodo: string;
  data: VendaDiaria[];
  totalRegistros: number;
}

export interface Totalizadores {
  totalVendasQtd: number;
  totalVendasVlr: number;
  totalTransfQtd: number;
  totalDevolQtd: number;
  totalDevolVlr: number;
}

export interface TotalizadoresResponse {
  success: boolean;
  message: string;
  periodo: string;
  totalizadores: Totalizadores;
}

@Injectable({
  providedIn: 'root'
})
export class VendasDiariasService {

  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) { }

  /**
   * Busca dados de vendas diárias
   * @param mes - Mês da consulta (01-12)
   * @param ano - Ano da consulta (YYYY)
   * @returns Observable com dados das vendas diárias
   */
  getVendasDiarias(mes: string, ano: string): Observable<VendasDiariasResponse> {
    const params = new HttpParams()
      .set('mes', mes)
      .set('ano', ano);

    return this.http.get<VendasDiariasResponse>(`${this.apiUrl}/vendas-diarias`, { params });
  }

  /**
   * Busca totalizadores do período
   * @param mes - Mês da consulta
   * @param ano - Ano da consulta
   * @returns Observable com totalizadores
   */
  getTotalizadores(mes: string, ano: string): Observable<TotalizadoresResponse> {
    const params = new HttpParams()
      .set('mes', mes)
      .set('ano', ano);

    return this.http.get<TotalizadoresResponse>(`${this.apiUrl}/vendas-diarias/totalizadores`, { params });
  }

  /**
   * Exporta dados para Excel/CSV
   * @param mes - Mês da consulta
   * @param ano - Ano da consulta
   * @param formato - 'excel' ou 'csv'
   * @returns Observable com arquivo para download
   */
  exportarDados(mes: string, ano: string, formato: 'excel' | 'csv'): Observable<Blob> {
    const params = new HttpParams()
      .set('mes', mes)
      .set('ano', ano)
      .set('formato', formato);

    return this.http.get(`${this.apiUrl}/vendas-diarias/export`, {
      params,
      responseType: 'blob'
    });
  }

  /**
   * Valida se o período informado é válido
   * @param mes - Mês (01-12)
   * @param ano - Ano (YYYY)
   * @returns true se válido
   */
  validarPeriodo(mes: string, ano: string): boolean {
    const mesNum = parseInt(mes, 10);
    const anoNum = parseInt(ano, 10);
    const anoAtual = new Date().getFullYear();

    return (
      mesNum >= 1 && mesNum <= 12 &&
      anoNum >= 2000 && anoNum <= anoAtual + 1
    );
  }

  /**
   * Formata número para exibição (brasileiro)
   * @param value - Valor numérico
   * @param decimais - Número de casas decimais
   * @returns String formatada
   */
  formatarNumero(value: number, decimais: number = 2): string {
    return new Intl.NumberFormat('pt-BR', {
      minimumFractionDigits: decimais,
      maximumFractionDigits: decimais
    }).format(value);
  }

  /**
   * Formata valor monetário
   * @param value - Valor numérico
   * @returns String formatada como moeda brasileira
   */
  formatarMoeda(value: number): string {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  }

  /**
   * Gera nome do arquivo para download
   * @param mes - Mês
   * @param ano - Ano  
   * @param formato - Formato do arquivo
   * @returns Nome do arquivo
   */
  gerarNomeArquivo(mes: string, ano: string, formato: string): string {
    const agora = new Date();
    const timestamp = agora.toISOString().slice(0, 19).replace(/[:-]/g, '');
    return `vendas_diarias_${mes}_${ano}_${timestamp}.${formato}`;
  }
}
