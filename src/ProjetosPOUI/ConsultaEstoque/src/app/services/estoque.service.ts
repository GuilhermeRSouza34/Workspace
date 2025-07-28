import { Injectable } from '@angular/core';
import { HttpClient, HttpParams, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, tap, map } from 'rxjs/operators';
import { environment } from '../../environments/environment';
import { ProdutoEstoque, FiltroConsulta, LocalEstoque, CategoriaEstoque } from '../models/estoque.model';

@Injectable({
  providedIn: 'root'
})
export class EstoqueService {
  private readonly apiUrl = environment.apiUrl;

  constructor(
    private http: HttpClient
  ) { }

  consultarEstoque(filtros: FiltroConsulta): Observable<ProdutoEstoque[]> {
    let params = new HttpParams();
    
    if (filtros.codigoProduto) {
      params = params.set('codigoProduto', filtros.codigoProduto);
    }
    if (filtros.descricaoProduto) {
      params = params.set('descricaoProduto', filtros.descricaoProduto);
    }
    if (filtros.categoria) {
      params = params.set('categoria', filtros.categoria);
    }
    if (filtros.local) {
      params = params.set('local', filtros.local);
    }
    if (filtros.somenteComSaldo) {
      params = params.set('somenteComSaldo', filtros.somenteComSaldo.toString());
    }

    console.log('🔍 Consultando estoque:', `${this.apiUrl}/consulta-estoque`, params.toString());

    return this.http.get<ProdutoEstoque[]>(`${this.apiUrl}/consulta-estoque`, { params })
      .pipe(
        tap((response: any) => console.log('✅ Estoque consultado:', response)),
        catchError(this.handleError<ProdutoEstoque[]>('consultarEstoque', []))
      );
  }

  obterLocais(): Observable<LocalEstoque[]> {
    console.log('📍 Buscando locais:', `${this.apiUrl}/locais-estoque`);
    
    return this.http.get<LocalEstoque[]>(`${this.apiUrl}/locais-estoque`)
      .pipe(
        tap((response: any) => console.log('✅ Locais obtidos:', response)),
        catchError(this.handleError<LocalEstoque[]>('obterLocais', []))
      );
  }

  obterCategorias(): Observable<CategoriaEstoque[]> {
    console.log('🏷️ Buscando categorias:', `${this.apiUrl}/categorias-estoque`);
    
    return this.http.get<CategoriaEstoque[]>(`${this.apiUrl}/categorias-estoque`)
      .pipe(
        tap((response: any) => console.log('✅ Categorias obtidas:', response)),
        catchError(this.handleError<CategoriaEstoque[]>('obterCategorias', []))
      );
  }

  obterProdutoPorCodigo(codigo: string): Observable<ProdutoEstoque> {
    console.log('📦 Buscando produto:', `${this.apiUrl}/produto-estoque/${codigo}`);
    
    return this.http.get<ProdutoEstoque>(`${this.apiUrl}/produto-estoque/${codigo}`)
      .pipe(
        tap((response: any) => console.log('✅ Produto obtido:', response)),
        catchError(this.handleError<ProdutoEstoque>('obterProdutoPorCodigo', {} as ProdutoEstoque))
      );
  }

  /**
   * Testa a conectividade com a API
   */
  testarConectividade(): Observable<any> {
    console.log('🧪 Testando conectividade:', `${this.apiUrl}/locais-estoque`);
    
    return this.http.get(`${this.apiUrl}/locais-estoque`)
      .pipe(
        tap(() => console.log('✅ API está respondendo')),
        catchError(this.handleError<any>('testarConectividade', null))
      );
  }

  /**
   * Manipulador de erros genérico
   */
  private handleError<T>(operation = 'operation', result?: T) {
    return (error: HttpErrorResponse): Observable<T> => {
      console.error('❌ Erro na operação:', operation, error);

      let errorMessage = '';
      
      if (error.error instanceof ErrorEvent) {
        // Erro do lado cliente
        errorMessage = `Erro de cliente: ${error.error.message}`;
      } else {
        // Erro do lado servidor
        switch (error.status) {
          case 0:
            errorMessage = 'Erro de conectividade: Verifique se o servidor Protheus está rodando e se as configurações de CORS estão corretas.';
            break;
          case 404:
            errorMessage = 'Endpoint não encontrado: Verifique se a API foi compilada e está ativa no Protheus.';
            break;
          case 500:
            errorMessage = 'Erro interno do servidor: Verifique os logs do Protheus.';
            break;
          default:
            errorMessage = `Erro do servidor: ${error.status} - ${error.message}`;
        }
      }

      console.error('Detalhes do erro:', errorMessage);
      
      // Retorna o resultado padrão se fornecido
      if (result !== undefined) {
        return new Observable<T>(observer => {
          observer.next(result);
          observer.complete();
        });
      }
      
      return throwError(() => new Error(errorMessage));
    };
  }
}
