import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { PoMenuItem } from '@po-ui/ng-components';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'Sistema de Consulta de Estoque';

  readonly menus: Array<PoMenuItem> = [
    { 
      label: 'Consulta de Estoque', 
      action: this.navegarParaConsulta.bind(this), 
      icon: 'po-icon-stock',
      shortLabel: 'Estoque'
    }
  ];

  constructor(private router: Router) {}

  private navegarParaConsulta(): void {
    this.router.navigate(['/consulta-estoque']);
  }
}
