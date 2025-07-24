import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { ProdutoEstoque, FiltroConsulta, LocalEstoque, CategoriaEstoque } from '../models/estoque.model';

@Injectable({
  providedIn: 'root'
})
export class EstoqueService {
  private readonly apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) { }

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

    return this.http.get<ProdutoEstoque[]>(`${this.apiUrl}/consulta-estoque`, { params });
  }

  obterLocais(): Observable<LocalEstoque[]> {
    return this.http.get<LocalEstoque[]>(`${this.apiUrl}/locais-estoque`);
  }

  obterCategorias(): Observable<CategoriaEstoque[]> {
    return this.http.get<CategoriaEstoque[]>(`${this.apiUrl}/categorias-estoque`);
  }

  obterProdutoPorCodigo(codigo: string): Observable<ProdutoEstoque> {
    return this.http.get<ProdutoEstoque>(`${this.apiUrl}/produto-estoque/${codigo}`);
  }
}
