// Interface para Liberações (ZZS)
export interface Liberacao {
  recno: number;
  filial: string;
  numLib: string;
  op: string;
  produto: string;
  corIBR: string;
  compMO: string;
  tCorrec: number;
  lote: string;
  quant: number;
  dataIni: string;
  horaIni: string;
  horaFim: string;
  tonalidade: string;
  resultado: string;
  usuario: string;
  maquina: string;
  observ: string;
}

// Interface para Correções (ZZT)
export interface Correcao {
  recno: number;
  filial: string;
  numLib: string;
  numAna: number;
  codPig: string;
  quantPig: number;
  dataIni: string;
  horaIni: string;
  horaFim: string;
  tecnico: string;
  tonalidade: string;
  compMO: string;
}

// Interface para Dashboard KPIs
export interface DashboardData {
  totalLib: number;
  totalCor: number;
  aprovados: number;
  reprovados: number;
  percAprov: number;
  mediaCorrOP: number;
  tempoMedLib: string;
  tecAtivo: string;
  pigMais: string;
}

// Interface para Resposta da API
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  total?: number;
  message?: string;
  filtros?: {
    dataIni: string;
    dataFim: string;
    filial: string;
  };
}

// Interface para Filtros
export interface Filtros {
  dataIni: string;
  dataFim: string;
  filial?: string;
  tpRel?: string;
}
