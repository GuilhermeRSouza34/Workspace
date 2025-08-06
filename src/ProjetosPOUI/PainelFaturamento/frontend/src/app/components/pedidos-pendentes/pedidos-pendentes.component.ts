import { Component } from '@angular/core';

@Component({
  selector: 'app-pedidos-pendentes',
  template: `
    <div class="pedidos-container">
      <h1>📋 Pedidos Pendentes</h1>
      <p>Lista de pedidos aguardando processamento.</p>
      
      <po-table
        [p-columns]="columns"
        [p-items]="pedidos"
        [p-striped]="true">
      </po-table>
      
      <br>
      
      <po-button 
        p-label="Voltar ao Dashboard" 
        p-kind="secondary"
        routerLink="/dashboard">
      </po-button>
    </div>
  `,
  styles: [`
    .pedidos-container {
      padding: 20px;
    }
  `]
})
export class PedidosPendentesComponent {
  
  columns = [
    { property: 'numero', label: 'Pedido' },
    { property: 'cliente', label: 'Cliente' },
    { property: 'valor', label: 'Valor', type: 'currency', format: 'BRL' },
    { property: 'status', label: 'Status' }
  ];

  pedidos = [
    { numero: '000001', cliente: 'Cliente A', valor: 1500.00, status: 'Pendente' },
    { numero: '000002', cliente: 'Cliente B', valor: 2500.00, status: 'Em Análise' },
    { numero: '000003', cliente: 'Cliente C', valor: 3200.00, status: 'Aprovado' }
  ];
}
