import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { DashboardComponent } from './components/dashboard/dashboard.component';
import { PedidosPendentesComponent } from './components/pedidos-pendentes/pedidos-pendentes.component';
import { OrcamentosComponent } from './components/orcamentos/orcamentos.component';

const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'pedidos-pendentes', component: PedidosPendentesComponent },
  { path: 'orcamentos', component: OrcamentosComponent },
  { path: '**', redirectTo: '/dashboard' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
