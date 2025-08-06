import { Component, OnInit } from '@angular/core';
import { PoMenuItem, PoPageDefault } from '@po-ui/ng-components';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
  title = 'Painel de Faturamento';
  
  readonly menus: Array<PoMenuItem> = [
    {
      label: 'Dashboard',
      action: () => this.router.navigate(['/dashboard']),
      icon: 'po-icon-chart-columns',
      shortLabel: 'Dashboard'
    },
    {
      label: 'Pedidos Pendentes',
      action: () => this.router.navigate(['/pedidos-pendentes']),
      icon: 'po-icon-clock',
      shortLabel: 'Pendentes'
    },
    {
      label: 'Ranking Clientes',
      action: () => this.router.navigate(['/ranking-clientes']),
      icon: 'po-icon-star',
      shortLabel: 'Ranking'
    },
    {
      label: 'Relatórios',
      action: () => this.router.navigate(['/relatorios']),
      icon: 'po-icon-document-double',
      shortLabel: 'Relatórios'
    }
  ];

  constructor(private router: any) { }

  ngOnInit(): void {
    // Inicialização do componente
  }
}
