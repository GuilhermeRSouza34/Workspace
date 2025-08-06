import { Component } from '@angular/core';

@Component({
  selector: 'app-dashboard',
  template: `
    <div class="dashboard-container">
      <h1>📊 Dashboard de Faturamento</h1>
      <p>Aqui será exibido o dashboard com KPIs e gráficos.</p>
      
      <po-widget>
        <h3>KPIs Principais</h3>
        
        <div class="po-row">
          <div class="po-md-3">
            <po-info p-label="Faturamento Total" p-value="R$ 150.000,00">
            </po-info>
          </div>
          <div class="po-md-3">
            <po-info p-label="Pedidos Pendentes" p-value="45">
            </po-info>
          </div>
          <div class="po-md-3">
            <po-info p-label="Clientes Ativos" p-value="128">
            </po-info>
          </div>
          <div class="po-md-3">
            <po-info p-label="Meta Mensal" p-value="85%">
            </po-info>
          </div>
        </div>
      </po-widget>
      
      <br>
      
      <po-button 
        p-label="Ver Pedidos Pendentes" 
        p-kind="primary"
        routerLink="/pedidos-pendentes">
      </po-button>
    </div>
  `,
  styles: [`
    .dashboard-container {
      padding: 20px;
    }
  `]
})
export class DashboardComponent {
}
