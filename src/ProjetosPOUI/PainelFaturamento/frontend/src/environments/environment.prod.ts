// Arquivo de configuração de ambiente para produção
export const environment = {
  production: true,
  apiUrl: '/rest', // URL relativa em produção
  appName: 'Painel Faturamento',
  version: '1.0.0',
  features: {
    enableLogging: false,
    enableDebug: false,
    enableNotifications: true
  },
  timeout: 30000,
  pageSize: 20
};
