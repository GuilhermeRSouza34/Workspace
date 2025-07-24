import { Component } from '@angular/core';
import { PoMenuItem, PoMenuPanelItem } from '@po-ui/ng-components';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'Consulta de Estoque';

  readonly menus: Array<PoMenuItem> = [
    { label: 'Consulta de Estoque', action: this.onClick.bind(this), icon: 'po-icon-stock' }
  ];

  private onClick() {
    // Navegação já está configurada no routing
  }
}
