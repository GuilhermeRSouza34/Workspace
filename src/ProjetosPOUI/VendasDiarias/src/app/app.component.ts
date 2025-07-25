import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <div class="app-container">
      <po-toolbar p-title="Sistema Protheus - Vendas Diárias"></po-toolbar>
      <router-outlet></router-outlet>
    </div>
  `,
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'Vendas Diárias - Sistema Protheus';
}
