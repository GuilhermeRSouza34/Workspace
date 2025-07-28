/**
 * Modelos de dados para o Relatório de Correção de Cor
 * Baseado nas tabelas ZZS (Liberações) e ZZT (Correções) do Protheus
 * Compatível com os endpoints do RCORAPI.tlpp
 */

export interface FiltrosRelatorio {
  dtIni: string;           // Data inicial no formato YYYY-MM-DD
  dtFim: string;           // Data final no formato YYYY-MM-DD
  filial?: string;         // Código da filial (opcional)
  tpRel?: string;          // Tipo do relatório: RESUMO, DETALHADO, ANALITICO
}

export interface ApiResponse<T> {
  success: boolean;        // Indica se a requisição foi bem-sucedida
  data: T;                 // Dados retornados pela API
  message?: string;        // Mensagem opcional
  total?: number;          // Total de registros (para paginação)
  error?: string;          // Mensagem de erro (se houver)
}

/**
 * Interface para dados de Liberação (tabela ZZS)
 * Representa uma liberação de cor no sistema Protheus
 */
export interface LiberacaoItem {
  numLib: string;          // ZZS_NUMLIB - Número da liberação
  op: string;              // ZZS_OP - Ordem de produção
  produto: string;         // ZZS_PROD - Código do produto
  corIBR: string;          // ZZS_CORIBR - Cor IBR
  compMO: string;          // ZZS_COMPMO - Componente MO
  lote: string;            // ZZS_LOTE - Lote
  quant: number;           // ZZS_QUANT - Quantidade
  dataIni: string;         // ZZS_DTINI - Data de início
  horaIni: string;         // ZZS_HRINI - Hora de início
  resultado: string;       // ZZS_RESULT - Resultado (APROVADO/REPROVADO/PENDENTE)
  usuario: string;         // ZZS_USER - Usuário responsável
  filial?: string;         // ZZS_FILIAL - Filial
  dataFim?: string;        // ZZS_DTFIM - Data de fim
  horaFim?: string;        // ZZS_HRFIM - Hora de fim
  observacao?: string;     // ZZS_OBS - Observações
  status?: string;         // ZZS_STATUS - Status
}

/**
 * Interface para dados de Correção (tabela ZZT)
 * Representa uma correção de cor no sistema Protheus
 */
export interface CorrecaoItem {
  numLib: string;          // ZZT_NUMLIB - Número da liberação relacionada
  numAna: number;          // ZZT_NUMANA - Número da análise
  codPig: string;          // ZZT_CODPIG - Código do pigmento
  quantPig: number;        // ZZT_QTDPIG - Quantidade do pigmento
  dataIni: string;         // ZZT_DTINI - Data de início
  horaIni: string;         // ZZT_HRINI - Hora de início
  tecnico: string;         // ZZT_TECNIC - Técnico responsável
  tonalidade: string;      // ZZT_TONAL - Tonalidade
  filial?: string;         // ZZT_FILIAL - Filial
  dataFim?: string;        // ZZT_DTFIM - Data de fim
  horaFim?: string;        // ZZT_HRFIM - Hora de fim
  status?: string;         // ZZT_STATUS - Status da correção
  observacao?: string;     // ZZT_OBS - Observações
  resultado?: string;      // ZZT_RESULT - Resultado da correção
}

/**
 * Interface para dados consolidados do Dashboard
 * Contém métricas calculadas dos dados de liberação e correção
 */
export interface DashboardData {
  totalLiberacoes: number;     // Total de liberações no período
  totalCorrecoes: number;      // Total de correções no período
  aprovadas: number;           // Liberações aprovadas
  reprovadas: number;          // Liberações reprovadas
  pendentes: number;           // Liberações pendentes
  percentualAprovacao: number; // Percentual de aprovação
  mediaTempoAnalise?: number;  // Tempo médio de análise (em horas)
  topProdutos?: ProductRanking[]; // Produtos com mais liberações
  topTecnicos?: TechnicianRanking[]; // Técnicos mais ativos
}

/**
 * Interface para ranking de produtos
 */
export interface ProductRanking {
  produto: string;         // Código do produto
  descricao?: string;      // Descrição do produto
  quantidade: number;      // Quantidade de liberações
  percentual: number;      // Percentual do total
}

/**
 * Interface para ranking de técnicos
 */
export interface TechnicianRanking {
  tecnico: string;         // Nome/código do técnico
  quantidade: number;      // Quantidade de análises
  percentual: number;      // Percentual do total
  mediaAprovacao: number;  // Média de aprovação do técnico
}

/**
 * Enum para tipos de relatório
 */
export enum TipoRelatorio {
  RESUMO = 'RESUMO',
  DETALHADO = 'DETALHADO',
  ANALITICO = 'ANALITICO'
}

/**
 * Enum para status de liberação/correção
 */
export enum StatusItem {
  APROVADO = 'APROVADO',
  REPROVADO = 'REPROVADO',
  PENDENTE = 'PENDENTE',
  CANCELADO = 'CANCELADO'
}

/**
 * Interface para configurações de exportação
 */
export interface ExportConfig {
  formato: 'excel' | 'pdf' | 'csv';
  incluirFiltros: boolean;
  incluirTotalizadores: boolean;
  nomeArquivo?: string;
}

/**
 * Interface para filtros avançados (para futuras implementações)
 */
export interface FiltrosAvancados extends FiltrosRelatorio {
  produto?: string;        // Filtro por produto específico
  tecnico?: string;        // Filtro por técnico
  resultado?: StatusItem;  // Filtro por resultado
  op?: string;             // Filtro por ordem de produção
  lote?: string;           // Filtro por lote
}

/**
 * Interface para paginação
 */
export interface PaginationConfig {
  page: number;            // Página atual (começando em 1)
  pageSize: number;        // Quantidade de itens por página
  totalItems: number;      // Total de itens disponíveis
  totalPages: number;      // Total de páginas
}

/**
 * Interface para dados paginados
 */
export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: PaginationConfig;
}

/**
 * Type guard para verificar se um item é uma Liberação
 */
export function isLiberacaoItem(item: any): item is LiberacaoItem {
  return item && typeof item.numLib === 'string' && typeof item.op === 'string';
}

/**
 * Type guard para verificar se um item é uma Correção
 */
export function isCorrecaoItem(item: any): item is CorrecaoItem {
  return item && typeof item.numLib === 'string' && typeof item.numAna === 'number';
}

/**
 * Utilitário para criar filtros padrão
 */
export function criarFiltrosPadrao(): FiltrosRelatorio {
  const hoje = new Date();
  const primeiroDia = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
  
  return {
    dtIni: primeiroDia.toISOString().split('T')[0],
    dtFim: hoje.toISOString().split('T')[0],
    filial: '01',
    tpRel: TipoRelatorio.RESUMO
  };
}
