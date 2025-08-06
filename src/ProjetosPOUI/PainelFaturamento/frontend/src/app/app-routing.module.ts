import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { DashboardComponent } from './components/dashboard/dashboard.component';
import { PedidosPendentesComponent } from './components/pedidos-pendentes/pedidos-pendentes.component';
import { RankingClientesComponent } from './components/ranking-clientes/ranking-clientes.component';
import { RelatoriosComponent } from './components/relatorios/relatorios.component';

const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'pedidos-pendentes', component: PedidosPendentesComponent },
  { path: 'ranking-clientes', component: RankingClientesComponent },
  { path: 'relatorios', component: RelatoriosComponent },
  { path: '**', redirectTo: '/dashboard' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
