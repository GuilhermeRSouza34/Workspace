export interface ProdutoEstoque {
  codigo: string;
  descricao: string;
  categoria: string;
  unidade: string;
  local: string;
  saldoAtual: number;
  saldoDisponivel: number;
  saldoReservado: number;
  custoMedio: number;
  precoVenda: number;
  ultimaMovimentacao: Date;
  ativo: boolean;
}

export interface FiltroConsulta {
  codigoProduto?: string;
  descricaoProduto?: string;
  categoria?: string;
  local?: string;
  somenteComSaldo?: boolean;
}

export interface LocalEstoque {
  codigo: string;
  descricao: string;
}

export interface CategoriaEstoque {
  codigo: string;
  descricao: string;
}
