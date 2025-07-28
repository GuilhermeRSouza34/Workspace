import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <po-toolbar p-title="Consulta de Estoque - Correção de Cor">
    </po-toolbar>
    <router-outlet></router-outlet>
  `,
  styles: []
})
export class AppComponent {
  title = 'Consulta de Estoque';
}
