// Arquivo de configuração de ambiente para desenvolvimento
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/rest', // URL do backend TLPP
  appName: 'Painel Faturamento',
  version: '1.0.0',
  features: {
    enableLogging: true,
    enableDebug: true,
    enableNotifications: true
  },
  timeout: 30000, // 30 segundos
  pageSize: 20 // Tamanho padrão de paginação
};
