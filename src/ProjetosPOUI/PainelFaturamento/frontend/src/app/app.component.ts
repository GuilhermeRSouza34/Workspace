import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-root',
  template: `
    <po-page-default p-title="Painel de Faturamento - POUI + TLPP">
      <div class="po-mt-3">
        <h2>🎉 Frontend funcionando!</h2>
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
          routerLink="/pedidos-pendentes"
          class="po-mr-2">
        </po-button>
        
        <po-button 
          p-label="Orçamentos" 
          p-kind="tertiary"
          p-icon="po-icon-finance"
          routerLink="/orcamentos">
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
  
  constructor(private router: Router) { }
}
