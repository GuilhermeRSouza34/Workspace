import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <po-page-default p-title="Painel de Faturamento - POUI + TLPP">
      <div class="po-mt-3">
        <p>Sistema de faturamento desenvolvido com PO-UI e Angular.</p>
        
        <po-button 
          p-label="Dashboard" 
          p-kind="primary"
          p-icon="po-icon-chart-columns"
          routerLink="/dashboard"
          class="po-mr-2">
        </po-button>
        
        <po-button 
          p-label="Pedidos Pendentes" 
          p-kind="secondary"
          p-icon="po-icon-list"
          routerLink="/pedidos-pendentes">
        </po-button>
        
        <router-outlet></router-outlet>
      </div>
    </po-page-default>
  `,
  styles: [`
    .po-mt-3 { margin-top: 1rem; }
    .po-mr-2 { margin-right: 0.5rem; }
  `]
})
export class AppComponent {
  title = 'Painel de Faturamento';
}
